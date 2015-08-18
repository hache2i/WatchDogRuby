module Wd
  module Actions
    class GetItemDetails

      def self.do user, itemId
        driveConnection = Files::DriveConnection.new
        driveConnection.authorize(user)

        result = Files::DriveApiHelper.get_item driveConnection, itemId
        item_data = result.data
        changes = Files::Changed.where fileId: itemId

        status = "2p" if item_data.parents.count > 1
        status = "r" if item_data.parents.count == 1 && changes.empty?

        if item_data.parents.count == 1 && !changes.empty?
          parent_id = changes[0].parentId
          parent_change = Files::Changed.where fileId: parent_id
          status = "fuck"
          status = "1p1pc" if parent_change.count == 1
        end

        { 
          drive_data: item_data,
          changes_data: changes,
          status: status
        }
      end

    end
  end
end