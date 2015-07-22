require_relative '../../wd_logger'
require_relative '../../files/lib/files_domain'
require_relative '../../files/lib/files_to_change'
require_relative '../../files/lib/root_folders'
require_relative '../../files/lib/children_folders'
require_relative '../../files/lib/drive_connection'
require_relative '../../users/lib/users_domain'
require_relative '../../wdconfig/lib/config_domain'
require_relative 'scheduler'
require_relative 'execution_log'

module WDDomain
	class Watchdog

		def initialize(aDomains)
			@executionLog = ExecutionLog.new
			@driveConnection = Files::DriveConnection.new
			@usersDomain = Users::UsersDomain.new
			@filesDomain = Files::FilesDomain.new @executionLog, @driveConnection
			@configDomain = WDConfig::ConfigDomain.new
			@scheduler = Scheduler.new(self, @executionLog)
			@domains = aDomains
		end

		def load
			configs = @configDomain.all
			@scheduler.scheduleAll configs
		end

		def getLog
			@executionLog
		end

		def getJobs
			@scheduler.getJobs
		end

		def getScheduledExecutionConfig(domain)
			@configDomain.getScheduledExecution(domain)
		end

		def configScheduledExecution(domain, admin, docsOwner, timing)
			config = @configDomain.configScheduledExecution(domain, admin, docsOwner, timing)
			@scheduler.schedule(config)
		end

		def scheduleOnce(domain, admin, docsOwner)
			@scheduler.scheduleOnce(domain, admin, docsOwner)
		end

		def unschedule(domain)
			@configDomain.unschedule(domain)
			@scheduler.unschedule(domain)
			@configDomain.getScheduledExecution(domain)
		end

		def isAdmin(email)
			@usersDomain.isAdmin email
		end

		def getUsers(email, domain)
			@usersDomain.getUsers(email, domain)
		end

		def files_under_common_structure users, domain_data
			rootFolders = Files::RootFolders.new @driveConnection, domain_data.docaccount
			folders = rootFolders.get
			WDLogger.info "getting files for #{ users }"
			user_files = Files::Children.new @driveConnection, users, folders, domain_data
			user_files.get
			WDLogger.info "getting files for #{ users } - FINISHED"
		end

		# def files_under_common_structure users, domain_data
		# 	rootFolders = Files::RootFolders.new @driveConnection, domain_data.docaccount
		# 	folders = rootFolders.get
		# 	users_files = []
		# 	users.each do |user|
		# 		WDLogger.info "getting files for #{ user }"
		# 		user_files = Files::Children.new @driveConnection, user, folders, domain_data
		# 		user_files = user_files.get
		# 		WDLogger.info "getting files for #{ user } - #{ user_files.length } found"
		# 		users_files.concat user_files
		# 	end
		# 	users_files
		# end

		def changePermissions(files, domain)
		    @filesDomain.changePermissions(files, domain)
		end

		def reassingOwnership(admin, docsOwner)
		end

		def getDocsAdmin(domain)
			@usersDomain.getDocsAdmin(domain)
		end

	end
end