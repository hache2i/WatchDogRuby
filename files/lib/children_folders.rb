require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'

module Files
  class Children
    def initialize(theDriveConnection, theUser, theFolders)
      @user = theUser
      @folders = theFolders
      @driveConnection = theDriveConnection
      @driveConnection.authorize(@user)
    end

    def get
      children = []
      @folders.each do |folder|
        folderChildren = getForFolder folder
        children.concat folderChildren
      end
      children
    end

    def getForFolder folder
      children = []
      begin
        p folder
        result = @driveConnection.client.execute(
          :api_method => @driveConnection.drive.files.list, 
          :parameters => assembleParams(getPageToken(result), folder)
        )
        p result.status
        raise UserFilesException if !result.status.eql? 200
        result.data.items.each do |item|
          children << { :title => item['title'], :id => item['id'], :owner => @user, :parent => folder[:id] }
        end
      end while hasNextPage? result
      children
    end

    def assembleParams pageToken, folder
      params = {'q' => "trashed = false and '" + folder[:id] + "' in parents"}
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