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

		def getUsers(email)
			@usersDomain.getUsers(email)
		end

		def getFiles(users)
			@filesDomain.getFiles(users)
		end

		def files_under_common_structure users, docaccount
			rootFolders = Files::RootFolders.new @driveConnection, docaccount
			folders = rootFolders.get
			users_files = []
			users.each do |user|
				user_files = Files::Children.new @driveConnection, user, folders
				user_files = user_files.get
				users_files.concat user_files
			end
			users_files
		end

		def findFilesToRetrieveOwnership(users, currentOwner)
			@filesDomain.findFilesToRetrieveOwnership(users, currentOwner)
		end

		def fixRoot(users)
			@filesDomain.fixRoot(users)
		end

		def unshare(users, withWho)
			@filesDomain.unshare(users, withWho)
		end

		def changePermissions(files, newOwner)
	    @filesDomain.changePermissions(files, newOwner)
		end

		def giveOwnershipBack(files, currentOwner)
	    @filesDomain.giveOwnershipBack(files, currentOwner)
		end

		def reassingOwnership(admin, docsOwner)
			userNames = @usersDomain.getUsers(admin).map(&:email)
			nonOwnerUsers = userNames.reject{|userName| userName.eql? docsOwner}
			domain = extractDomain(admin)
			if @domains.allowExecution(domain, nonOwnerUsers.length)
				nonOwnerUsers.each do |user|
					files = @filesDomain.getFiles([user])
					@filesDomain.changePermissions(Files::FilesToChange.unmarshall(files.to_s), docsOwner)
				end
			end
		end

		private

		def extractDomain(email)
			email.scan(/(.+)@(.+)/)[0][1]
		end

	end
end