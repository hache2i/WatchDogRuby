require_relative '../../wd_logger'

module Files
  class DriveApiHelper

    def self.create_owner_permission driveConnection, email, file_id
      WDLogger.debug("DriveApiHelper.create_owner_permission")
      new_permission = driveConnection.drive.permissions.insert.request_schema.new({
        'value' => email,
        'type' => 'user',
        'role' => 'owner'
      })
      api_result = driveConnection.client.execute(
        :api_method => driveConnection.drive.permissions.insert,
        :body_object => new_permission,
        :parameters => { 'fileId' => file_id }
      )
      { :status => api_result.status }
    rescue => e
      WDLogger.error "DriveApiHelper.create_owner_permission - #{ e.inspect }"
      { :status => 666 }
    end

    def self.remove_parent driveConnection, fileId, parentId
      driveConnection.client.execute(
        :api_method => driveConnection.drive.parents.delete,
        :parameters => {
          'fileId' => fileId,
          'parentId' => parentId
        }
      )
    end

    def self.list_files driveConnection, parameters
      api_result = driveConnection.client.execute(
        :api_method => driveConnection.drive.files.list, 
        :parameters => parameters
      )
      DriveApiResult.new api_result.status, api_result
    rescue => e
      WDLogger.error "DriveApiHelper.list_files - #{ e.inspect }"
      DriveApiResult.new 666
    end

    def self.children driveConnection, parameters
      api_result = driveConnection.client.execute(
        :api_method => driveConnection.drive.children.list, 
        :parameters => parameters
      )
      DriveApiResult.new api_result.status, api_result
    rescue => e
      WDLogger.error "DriveApiHelper.list_files - #{ e.inspect }"
      DriveApiResult.new 666
    end

    def self.list_permissions driveConnection, parameters
      driveConnection.client.execute(
        :api_method => driveConnection.drive.permissions.list, 
        :parameters => parameters
      )
    end

    def self.delete_permission driveConnection, fileId, permissionId
      driveConnection.client.execute(
        :api_method => driveConnection.drive.permissions.delete,
        :parameters => {
          'fileId' => fileId,
          'permissionId' => permissionId
        }
      )
    end

    def self.update_permission driveConnection, fileId, permission
      WDLogger.debug("DriveApiHelper.update_permission")
      api_result = driveConnection.client.execute(
        :api_method => driveConnection.drive.permissions.update,
        :body_object => permission,
        :parameters => {
          'fileId' => fileId,
          'permissionId' => permission['id'],
          'transferOwnership' => true
        }
      )
      { :status => api_result.status }
    rescue => e
      WDLogger.error "DriveApiHelper.update_permission - #{ e.inspect }"
      { :status => 666 }
    end

    def self.get_current_permission_for driveConnection, email, fileId
      api_result = driveConnection.client.execute(
        :api_method => driveConnection.drive.permissions.list,
        :parameters => {
          'fileId' => fileId
        }
      )

      if api_result.status == 200
        permission = api_result.data.items.select{ |item| item["emailAddress"] == email }.first
      else
        p "fuck"
      end
      permission
    rescue
      nil
    end

  end

  class DriveApiResult

    attr_reader :status, :data

    def initialize status, result = nil
      @status = status
      @data = result.data unless result.nil?
    end

    def success?
      @status == 200
    end

  end

end

