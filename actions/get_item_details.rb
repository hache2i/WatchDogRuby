module Wd
  module Actions
    class GetItemDetails

      def self.do user, itemId
        driveConnection = Files::DriveConnection.new
        driveConnection.authorize(user)

        result = Files::DriveApiHelper.get_item driveConnection, itemId

        changes = Files::Changed.where fileId: itemId

        { 
          drive_data: result.data,
          changes_data: changes
        }
      end

    end
  end
end