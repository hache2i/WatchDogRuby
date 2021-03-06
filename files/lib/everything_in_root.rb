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

          if item.parents.count == 1
            if changes.empty?
              status = "r"
            else
              parent_id = changes[0].parentId
              parent_change = Changed.where fileId: parent_id
              status = "1p#{ parent_change.count }pc"
            end
          end

          if item.parents.count > 1
            if changes.empty?
              status = "2p"
            else
              parent_id = changes[0].parentId
              parent_change = Changed.where fileId: parent_id
              coincidence = item.parents.select { |parent| parent['id'] == parent_id }
              status = "2p#{ parent_change.count }pc"
              status = "2p1pc1c" if parent_change.count == 1 && coincidence.count > 0
            end
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