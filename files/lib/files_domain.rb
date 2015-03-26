require 'google/api_client'

require_relative 'service_account'
require_relative 'user_files_domain'
require_relative 'user_files_exception'
require_relative 'user_files_to_change'
require_relative 'drive_api_helper'

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
				user_files = Changed.find(userFilesToChange.getFiles.map {|file| file["id"]})
				userFilesDomain.changeUserFilesPermissions user_files
			end
		end

	end
end
