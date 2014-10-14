require_relative 'watchdog'
require_relative '../../wdadmin/lib/domains'

module Watchdog
	module Global
		module Watchdog
			extend self

			def init
				watchdog
			end

			def getLog
				watchdog.getLog
			end

			def getJobs
				watchdog.getJobs
			end

			def getScheduledExecutionConfig(domain)
				watchdog.getScheduledExecutionConfig domain
			end

			def configScheduledExecution(domain, admin, docsOwner, timing)
				watchdog.configScheduledExecution domain, admin, docsOwner, timing
			end

			def scheduleOnce(domain, admin, docsOwner)
				watchdog.scheduleOnce domain, admin, docsOwner
			end

			def unschedule(domain)
				watchdog.unschedule domain
			end

			def isAdmin(email)
				watchdog.isAdmin email
			end

			def getUsers(email)
				watchdog.getUsers email
			end

			def getFiles(users)
				watchdog.getFiles users
			end

			def findFilesToRetrieveOwnership(users, currentOwner)
				watchdog.findFilesToRetrieveOwnership users, currentOwner
			end

			def getRootFoldersSharedBy(user, docaccount)
				watchdog.getRootFoldersSharedBy user, docaccount
			end

			def getChildren user, docaccount
				watchdog.getChildren user, docaccount
			end

			def fixRoot(users)
				watchdog.fixRoot users
			end

			def unshare(users, withWho)
				watchdog.unshare users, withWho
			end

			def changePermissions(files, newOwner)
				watchdog.changePermissions files, newOwner
			end

			def giveOwnershipBack(files, currentOwner)
				watchdog.giveOwnershipBack files, currentOwner
			end

			def reassingOwnership(admin, docsOwner)
				watchdog.reassingOwnership admin, docsOwner
			end

			private 

			def watchdog
				@watchdog ||= load
			end

			def load
			    wd = WDDomain::Watchdog.new(Domains)
			    wd.load
			    wd
			end
		end
	end
end
