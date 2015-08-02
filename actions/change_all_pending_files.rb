require_relative '../wd_logger'
require_relative "../files/lib/changed"
require_relative "../files/lib/drive_connection"
require_relative "../files/lib/user_files_domain"

module Wd
	module Actions
		class ChangeAllPendingFiles
			def self.do domain, filter
				users_with_pending_files = Files::Changed.users domain if filter.nil?
				users_with_pending_files = filter["oldOwner"] unless filter.nil?
	
				thrs = []			
				Thread.abort_on_exception = true
				users_with_pending_files.reverse.each do |user|
					thrs << Thread.new {
						WDLogger.debug "started thread to change permissions for #{user}"
						user_files = Files::Changed.pending_for_user user
						userFilesDomain = Files::UserFilesDomain.new Files::DriveConnection.new, user, domain
						userFilesDomain.changeUserFilesPermissions user_files
					}
				end

				thrs.each { |thr| thr.join }
			end
		end
	end
end