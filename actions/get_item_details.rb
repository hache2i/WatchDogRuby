module Wd
  module Actions
    class GetItemDetails

      def self.do user, itemId
        driveConnection = Files::DriveConnection.new
        driveConnection.authorize(user)

        result = Files::DriveApiHelper.get_item driveConnection, itemId
        item_data = result.data
        changes = Files::Changed.where fileId: itemId

        parent_change = {}
        if item_data.parents.count == 1
          parent_id = changes[0].parentId
          parent_change = Files::Changed.where fileId: parent_id
        end

        { 
          drive_data: item_data,
          changes_data: changes,
          parent_change: parent_change
        }
      end

    end
  end
end