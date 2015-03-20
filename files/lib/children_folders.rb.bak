require_relative 'user_files'

module Files
  class Children
    def initialize(theDriveConnection, theUser, theFolders, domain_data)
      theDriveConnection.authorize(domain_data.docaccount)
      @user = theUser
      @domain_data = domain_data
      @commands = theFolders.map do |folder|
        FolderChildren.new theDriveConnection, theUser, folder, domain_data
      end
    end

    def get
      children = []
      @commands.each do |command|
        command.exec
        children.concat command.children
        WDLogger.debug "getting files for #{ @user } - #{ command.children.length } more added (not finished yet - #{children.length.to_s} until now)", @domain_data.name, @user unless command.children.empty?
        @commands.concat command.commands
      end
      WDLogger.debug "getting files for #{ @user } - #{ children.length } - FINISHED", @domain_data.name, @user
      children
    end

  end

  class FolderChildren

    attr_accessor :children, :commands

    def initialize theDriveConnection, theUser, theFolder, domain_data, path = ""
      @path = "#{path}/#{theFolder[:title]}"
      @user = theUser
      @folder = theFolder
      @driveConnection = theDriveConnection
      @commands = []
      @children = []
      @domain_data = domain_data
    end

    def exec
      WDLogger.debug "checking folder #{@folder.inspect}", @domain_data.name, @user
      begin
        result = DriveApiHelper.list_files @driveConnection, assembleParams(getPageToken(result))
        break unless result.success?
        result.data.items.each do |item|
          is_a_folder = item["mimeType"].eql? "application/vnd.google-apps.folder"

          current_owners = item['owners'].map{ |owner| owner["emailAddress"] }
          childData = { 
            :title => item['title'], 
            :id => item['id'], 
            :owner => current_owners, 
            :parent => @folder[:id],
            :isFolder => is_a_folder
          }

          if i_own_the_item(item)
            change_proposal = changed childData
            Changed.create_pending change_proposal
            @children << childData
          end
          @commands << FolderChildren.new(@driveConnection, @user, childData, @domain_data, @path) if is_a_folder
        end
      end while hasNextPage? result
    end

    def changed fileData
      {
        :fileId => fileData[:id],
        :oldOwner => @user,
        :newOwner => @domain_data.docaccount,
        :parentId => fileData[:parent],
        :title => fileData[:title],
        :domain => @domain_data.name,
        :path => @path,
        :isFolder => fileData[:isFolder]
      }
    end

    def i_own_the_item item
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