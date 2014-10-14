require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'

module Files
  class RootFolders
    def initialize(theDriveConnection, theUser)
      @user = theUser
      @driveConnection = theDriveConnection
      @driveConnection.authorize(@user)
    end

    def get
      folders = []
      begin
        result = @driveConnection.client.execute(
          :api_method => @driveConnection.drive.files.list, 
          :parameters => assembleParams(getPageToken(result))
        )
        raise UserFilesException if !result.status.eql? 200
        result.data.items.each do |item|
          folders << { :title => item['title'], :id => item['id'] }
        end
      end while hasNextPage? result
      folders
    end

    def assembleParams pageToken
      params = {'q' => "trashed = false and 'root' in parents and mimeType = 'application/vnd.google-apps.folder'"}
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