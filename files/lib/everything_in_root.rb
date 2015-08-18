require_relative 'user_files'
require_relative 'changed'

module Files
  class EverythingInRoot
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
          changes = Changed.where fileId: item['id']

          status = "2p" if item.parents.count > 1
          if item.parents.count > 1 && !changes.empty?
            parent_id = changes[0].parentId
            parent_change = Changed.where fileId: parent_id
            status = "fuck"
            status = "2p1pc" if parent_change.count == 1
          end

          status = "r" if item.parents.count == 1 && changes.empty?

          if item.parents.count == 1 && !changes.empty?
            parent_id = changes[0].parentId
            parent_change = Changed.where fileId: parent_id
            status = "fuck"
            status = "1p1pc" if parent_change.count == 1
          end

          folders << { :title => item['title'], :id => item['id'], :status => status }
        end
      end while hasNextPage? result
      folders
    end

    def assembleParams pageToken
      params = {'q' => "trashed = false and 'root' in parents"}
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