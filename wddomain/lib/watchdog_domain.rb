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

			def getUsers(email, domain)
				watchdog.getUsers email, domain
			end

			def files_under_common_structure users, domain_data
				watchdog.files_under_common_structure users, domain_data
			end

			def changePermissions(files, domain)
				watchdog.changePermissions files, domain
			end

			def reassingOwnership(admin, docsOwner)
				watchdog.reassingOwnership admin, docsOwner
			end

			def getDocsAdmin(domain)
				watchdog.getDocsAdmin(domain)
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
