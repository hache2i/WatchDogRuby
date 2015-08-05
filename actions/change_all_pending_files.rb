require_relative '../wd_logger'
require_relative "../files/lib/changed"
require_relative "../files/lib/drive_connection"
require_relative "../files/lib/user_files_domain"
require_relative '../wddomain/lib/threads'

module Wd
	module Actions
		class ChangeAllPendingFiles
			def self.do domain, filter
				users_with_pending_files = Files::Changed.users_with_pending_files domain if filter.nil? || filter[:oldOwner].nil?
				users_with_pending_files = filter[:oldOwner] unless filter.nil? || filter[:oldOwner].nil?
	
				thrs = []			
				Thread.abort_on_exception = true
				users_with_pending_files.reverse.each do |user|
					thr = Thread.new {
						WDLogger.debug "started thread to change permissions for #{user}"
						user_files = Files::Changed.pending_for_user user
						userFilesDomain = Files::UserFilesDomain.new Files::DriveConnection.new, user, domain
						userFilesDomain.changeUserFilesPermissions user_files
					}
					thr[:name] = "change permissions process for #{user} started at #{Time.now.to_s}"
					thrs << thr
					Watchdog::Global::Threads.add thr
				end

				thrs.each { |thr| thr.join }
			end
		end
	end
end