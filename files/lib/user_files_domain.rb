require_relative '../../wd_logger'
require_relative 'user_files'
require_relative 'changed'

module Files
	class UserFilesDomain
		def initialize aDriveConnection, aUser, aDomain
			@domain = aDomain
			@user = aUser
			@driveConnection = aDriveConnection
			@driveConnection.authorize @user
		end

	    def change_file_permission file
	    	change_proposal = Changed.find(file["id"])
	    	return unless file["newOwner"] != file["oldOwner"]
			new_owner_permission = DriveApiHelper.get_current_permission_for @driveConnection, file["newOwner"], file["fileId"]
			if new_owner_permission.nil?
				api_result = DriveApiHelper.create_owner_permission @driveConnection, file["newOwner"], file["fileId"]
			else
				new_owner_permission.role = "owner"
				api_result = DriveApiHelper.update_permission @driveConnection, file["fileId"], new_owner_permission
			end
			if api_result[:status] == 200
		    	change_proposal.update_attributes!(pending: false, executed: Time.now.to_i)
			else
				WDLogger.debug("(¡¡¡ FAILED !!!) change permission file '#{file["title"]}' #{api_result[:status].to_s}")
			end
	    end

		def changeUserFilesPermissions files
			WDLogger.debug("change permissions for #{files.length.to_s} files")
			files.each do |file|
				WDLogger.debug("change permission file: " + file.inspect)
				change_file_permission file
			end
		end


	end
end