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
			p "__________________change permissions"
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
				p "__________________change permissions - success"
				p change_proposal.inspect
				change_proposal.update_attributes!(pending: false, executed: Time.now.to_i)
				p change_proposal.inspect
				p Changed.find(change_proposal.id)
			else
				p "__________________change permissions - fail"
				WDLogger.error("(¡ FALLO !) cambio de propiedad '#{file.title}' - #{api_result[:status].to_s}", @domain, @user)
			end
		end

		def changeUserFilesPermissions files
			return if files.nil? || files.empty?

			WDLogger.info("cambiando propiedad de #{files.length.to_s} ficheros", @domain, @user)
			pending = files.size
			files.each do |file|
				WDLogger.info "cambiando propiedad de #{file.path} a #{file.newOwner}", @domain, @user
				WDLogger.debug("change ownership file: " + file.inspect, @domain, @user)
				change_file_permission file
				pending = pending.pred
				WDLogger.info("#{pending} ficheros pendientes", @domain, @user)
			end
			WDLogger.info("cambiando propiedad de #{files.length.to_s} ficheros TERMINADO", @domain, @user)
		end


	end
end