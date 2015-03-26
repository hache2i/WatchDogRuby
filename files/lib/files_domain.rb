require 'google/api_client'

require_relative 'service_account'
require_relative 'user_files_domain'
require_relative 'user_files_exception'
require_relative 'user_files_to_change'
require_relative 'drive_api_helper'
require_relative '../../wd_logger'

module Files
	class FilesDomain

		def initialize executionLog, driveConnection
			@executionLog = executionLog
			@driveConnection = driveConnection
		end

		def changePermissions(domainFilesToChange, domain)
			domainFilesToChange.each do |userFilesToChange|
				user = userFilesToChange.getEmail
				userFilesDomain = UserFilesDomain.new @driveConnection, user, domain
				files_ids = userFilesToChange.getFiles.map {|file| file["id"]}
				user_files = Changed.find(files_ids)
				userFilesDomain.changeUserFilesPermissions user_files
			end
		end

	end
end
