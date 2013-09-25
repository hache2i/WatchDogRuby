require_relative 'domains_status'

module Watchdog
	module Global
		module Domains
			extend self

			def self.list
				domains.list
			end

			def self.active?(domain)
				domains.active?(domain)
			end

			def self.activate(domain, licenses = nil)
				domains.activate(domain, licenses)
			end

			def self.clear
				domains.clear
			end

			def self.desactivate(domain)
				domains.desactivate domain
			end

			def self.inactive
				domains.inactive
			end

			def self.licenses(domain)
				domains.licenses domain
			end

			def self.allowExecution(domain, usersNumber)
				domains.allowExecution domain, usersNumber
			end

			private

			def domains
				@domains ||= load
			end

			def load
				domains = WDAdmin::DomainsStatus.new
				domains.load
				domains
			end
		end
	end
end