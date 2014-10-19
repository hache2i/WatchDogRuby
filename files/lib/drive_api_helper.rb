module Files
  class DriveApiHelper

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
      driveConnection.client.execute(
        :api_method => driveConnection.drive.files.list, 
        :parameters => parameters
      )
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
      api_result = driveConnection.client.execute(
        :api_method => driveConnection.drive.permissions.update,
        :body_object => permission,
        :parameters => {
          'fileId' => fileId,
          'permissionId' => permission['id'],
          'transferOwnership' => true
        }
      )
      api_result
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
    end

  end
end