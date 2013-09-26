module WDAdmin
	class DomainLicenses
		attr_accessor :domain, :licenses
		def initialize (aDomain, aLicenses)
			@domain = aDomain
			@licenses = aLicenses
		end
	end
end