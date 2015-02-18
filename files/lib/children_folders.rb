require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'

module Files
  class Children
    def initialize(theDriveConnection, theUser, theFolders, docaccount, domain)
      theDriveConnection.authorize(theUser)
      @user = theUser
      @commands = theFolders.map do |folder|
        FolderChildren.new theDriveConnection, theUser, folder, docaccount, domain
      end
    end

    def get
      children = []
      @commands.each do |command|
        command.exec
        children.concat command.children
        WDLogger.info "getting files for #{ @user } - #{ command.children.length } more added (not finished yet - #{children.length.to_s} until now)" unless command.children.empty?
        @commands.concat command.commands
      end
      WDLogger.info "getting files for #{ @user } - #{ children.length } - FINISHED"
      children
    end

  end

  class FolderChildren

    attr_accessor :children, :commands

    def initialize theDriveConnection, theUser, theFolder, docaccount, domain
      @user = theUser
      @folder = theFolder
      @driveConnection = theDriveConnection
      @commands = []
      @children = []
      @docaccount = docaccount
      @domain = domain
    end

    def exec
      WDLogger.info "checking folder #{@folder.inspect}"
      begin
        result = DriveApiHelper.list_files @driveConnection, assembleParams(getPageToken(result))
        break unless result.success?
        result.data.items.each do |item|
          childData = { :title => item['title'], :id => item['id'], :owner => @user, :parent => @folder[:id] }
          if i_own_the_folder(item)
            change_file_permission childData
            @children << childData
          end
          is_a_folder = item["mimeType"].eql? "application/vnd.google-apps.folder"
          @commands << FolderChildren.new(@driveConnection, @user, childData, @docaccount, @domain) if is_a_folder
        end
      end while hasNextPage? result
    end

    def change_file_permission file
      new_owner_permission = DriveApiHelper.get_current_permission_for @driveConnection, @docaccount, file[:id]
      if new_owner_permission.nil?
        api_result = DriveApiHelper.create_owner_permission @driveConnection, @docaccount, file[:id]
      else
        new_owner_permission.role = "owner"
        api_result = DriveApiHelper.update_permission @driveConnection, file[:id], new_owner_permission
      end
      if api_result[:status] == 200
        Changed.create changed file
      else
        WDLogger.debug("(¡¡¡ FAILED !!!) change permission file '#{file[:title]}' #{api_result[:status].to_s}")
      end
    end

    def changed fileData
      {
        :fileId => fileData[:id],
        :oldOwner => @user,
        :newOwner => @docaccount,
        :parentId => fileData[:parent],
        :title => fileData[:title],
        :domain => @domain
      }
    end

    def i_own_the_folder item
      !(item["owners"].find_all { |item| item["emailAddress"].eql? @user }).empty?
    end

    def assembleParams pageToken
      not_trashed = "trashed = false"
      child_of_folder = "'" + @folder[:id] + "' in parents"
      i_own = "'" + @user + "' in owners "
      is_folder = "mimeType = 'application/vnd.google-apps.folder'"
      is_not_folder = "mimeType != 'application/vnd.google-apps.folder'"

      query = myand [not_trashed, child_of_folder, myor([myand([i_own, is_not_folder]), is_folder])]

      params = { 'q' => query }
      params.merge!('pageToken' => pageToken) if !pageToken.empty?
      params
    end

    def myand params
      query = params.inject{ |query, param| query = query + " and " + param }
      "(" + query + ")"
    end

    def myor params
      query = params.inject{ |query, param| query = query + " or " + param }
      "(" + query + ")"
    end

    def getPageToken(result)
      return '' if result.nil? || result.data.nil?
      return result.data.next_page_token if hasNextPage? result
      ''
    end

    def hasNextPage?(result)
      !result.data.next_page_token.nil? && !result.data.next_page_token.empty?
    end

  end
end