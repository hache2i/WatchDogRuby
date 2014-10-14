require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'

module Files
  class Children
    def initialize(theDriveConnection, theUser, theFolders)
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
      @driveConnection.authorize(@user)
      @commands = []
      @children = []
    end

    def exec
      begin
        result = @driveConnection.client.execute(
          :api_method => @driveConnection.drive.files.list, 
          :parameters => assembleParams(getPageToken(result))
        )
        raise UserFilesException if !result.status.eql? 200
        result.data.items.each do |item|
          childData = { :title => item['title'], :id => item['id'], :owner => @user, :parent => @folder[:id] }
          @children << childData
          is_a_folder = item["mimeType"].eql? "application/vnd.google-apps.folder"
          @commands << FolderChildren.new(@driveConnection, @user, childData) if is_a_folder
        end
      end while hasNextPage? result
    end

    def assembleParams pageToken
      params = {'q' => "trashed = false and '" + @folder[:id] + "' in parents and '" + @user + "' in owners "}
      params.merge!('pageToken' => pageToken) if !pageToken.empty?
      params
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