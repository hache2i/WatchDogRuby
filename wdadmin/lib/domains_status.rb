require_relative 'domain_status'
require_relative 'domain_not_specified_exception'
require_relative 'licenses_not_specified_exception'

module WDAdmin
	class DomainsStatus

		def initialize
			@active = []
			@inactive =[]
		end

		def load
			@active.concat DomainStatus.where(active: true).collect{|domainStatus| domainStatus.domain}
			@inactive.concat DomainStatus.where(active: false).collect{|domainStatus| domainStatus.domain}
		end

		def active?(domain)
			@active.include?(domain)
		end

		def activate(domain, licenses)
			checkParams domain, licenses
			createActive domain, licenses
			@active << domain if !@active.include?(domain)
			@inactive.delete domain if @inactive.include?(domain)
		end

		def reactivate(domain)
			updateToActive domain
			@active << domain if !@active.include?(domain)
			@inactive.delete domain if @inactive.include?(domain)
		end

		def list
			@active
		end

		def desactivate(domain)
			updateToInactive domain
			@active.delete domain
			@inactive << domain
		end

		def clear
			@active.clear
			@inactive.clear
		end

		def inactive
			@inactive
		end

		def licenses(domain)
			DomainStatus.find_by(domain: domain).licenses
		end

		def allowExecution(domain, usersNumber)
			isActive = active?(domain)
			hasLicenses = licenses(domain) >= usersNumber
			puts "The domain " + domain + " is not active!!" if !isActive
			puts "The domain " + domain + " has not enought licenses!!" if !hasLicenses
			isActive && hasLicenses
		end

		private 

		def checkParams (domain, licenses)
			raise DomainNotSpecifiedException if notValid domain
			raise LicensesNotSpecifiedException if notValid licenses
		end

		def notValid(field)
			field.nil? || field.empty?
		end

		def updateToInactive(domain)
			domainStatus = DomainStatus.find_or_create_by(domain: domain)
			domainStatus.update_attributes({ :active => false })
			domainStatus
		end

		def createActive(domain, licenses)
			domainStatus = DomainStatus.find_or_create_by(domain: domain)
			domainStatus.update_attributes({ :active => true, :licenses => licenses })
			domainStatus
		end

		def updateToActive(domain)
			domainStatus = DomainStatus.find_or_create_by(domain: domain)
			domainStatus.update_attributes({ :active => true })
			domainStatus
		end

	end
end