require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'

module Files
  class Children
    def initialize(theDriveConnection, theUser, theFolders)
      theDriveConnection.authorize(theUser)
      @commands = theFolders.map do |folder|
        FolderChildren.new theDriveConnection, theUser, folder
      end
    end

    def get
      children = []
      @commands.each do |command|
        command.exec
        children.concat command.children
        @commands.concat command.commands
      end
      children
    end

  end

  class FolderChildren

    attr_accessor :children, :commands

    def initialize theDriveConnection, theUser, theFolder
      @user = theUser
      @folder = theFolder
      @driveConnection = theDriveConnection
      @commands = []
      @children = []
    end

    def exec
      begin
        result = DriveApiHelper.list_files @driveConnection, assembleParams(getPageToken(result))
        p "result status"
        p result.status
        raise UserFilesException if !result.status.eql? 200
        result.data.items.each do |item|
          childData = { :title => item['title'], :id => item['id'], :owner => @user, :parent => @folder[:id] }
          @children << childData if i_own_the_folder(item)
          is_a_folder = item["mimeType"].eql? "application/vnd.google-apps.folder"
          @commands << FolderChildren.new(@driveConnection, @user, childData) if is_a_folder
        end
      end while hasNextPage? result
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