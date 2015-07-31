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
			WDLogger.debug "UserFilesDomain initialized for #{@user}"
		end

	    def change_file_permission file
			WDLogger.info "changing permission for file #{file.path} from #{file.oldOwner} to #{file.newOwner}"
	    	change_proposal = file
	    	return unless file.newOwner != file.oldOwner
			new_owner_permission = DriveApiHelper.get_current_permission_for @driveConnection, file.newOwner, file.fileId
			if new_owner_permission.nil?
				api_result = DriveApiHelper.create_owner_permission @driveConnection, file.newOwner, file.fileId
			else
				new_owner_permission.role = "owner"
				api_result = DriveApiHelper.update_permission @driveConnection, file.fileId, new_owner_permission
			end
			if api_result[:status] == 200
		    	change_proposal.update_attributes!(pending: false, executed: Time.now.to_i)
			else
				WDLogger.error("(¡¡¡ FAILED !!!) change permission file '#{file.title}' #{api_result[:status].to_s}", @domain, @user)
			end
	    end

		def changeUserFilesPermissions files
			WDLogger.info("change permissions for #{files.length.to_s} files", @domain, @user)
			files.each do |file|
				WDLogger.debug("change permission file: " + file.inspect, @domain, @user)
				change_file_permission file
			end
			WDLogger.info("change permissions for #{files.length.to_s} files FINISHED", @domain, @user)
		end


	end
end