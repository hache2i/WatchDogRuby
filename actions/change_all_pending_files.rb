require_relative "../files/lib/changed"
require_relative "../files/lib/drive_connection"
require_relative "../files/lib/user_files_domain"

module Wd
	module Actions
		class ChangeAllPendingFiles
			def self.do domain
				users_with_pending_files = Files::Changed.users domain
				users_with_pending_files.each do |user|
					user_files = Files::Changed.pending_for_user user
					userFilesDomain = Files::UserFilesDomain.new Files::DriveConnection.new, user, domain
					userFilesDomain.changeUserFilesPermissions user_files
				end
			end
		end
	end
end