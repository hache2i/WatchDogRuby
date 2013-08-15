require_relative '../../files/lib/files_domain'
require_relative '../../files/lib/files_to_change'
require_relative '../../users/lib/users_domain'
require_relative '../../wdconfig/lib/config_domain'
require_relative 'scheduler'

module WDDomain
	class Watchdog

		def initialize
			@usersDomain = Users::UsersDomain.new
			@filesDomain = Files::FilesDomain.new
			@configDomain = WDConfig::ConfigDomain.new
			@scheduler = Scheduler.new(self)
		end

		def load
			configs = @configDomain.all
			@scheduler.scheduleAll configs
		end

		def getScheduledExecutionConfig(domain)
			@configDomain.getScheduledExecution(domain)
		end

		def configScheduledExecution(domain, admin, docsOwner, timing)
			config = @configDomain.configScheduledExecution(domain, admin, docsOwner, timing)
			@scheduler.schedule(config)
		end

		def unschedule(domain)
			@configDomain.unschedule(domain)
			@scheduler.unschedule(domain)
			@configDomain.getScheduledExecution(domain)
		end

		def getUsers(email)
			@usersDomain.getUsers(email)
		end

		def getFiles(users)
			@filesDomain.getFiles(users)
		end

		def changePermissions(files, newOwner)
		    @filesDomain.changePermissions(files, newOwner)
		end

		def reassingOwnership(admin, docsOwner)
			userNames = @usersDomain.getUsers(admin)
			files = @filesDomain.getFiles(userNames)
			changed = @filesDomain.changePermissions(Files::FilesToChange.unmarshall(files.to_s), docsOwner)
			changed
		end
	end
end