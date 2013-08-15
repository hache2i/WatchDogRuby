require 'mongoid'

module WDConfig
	class ExecutionConfiguration

		include Mongoid::Document

		field :domain, :type => String
		field :docsOwner, :type => String
		field :timing, :type => Integer
		field :admin, :type => String
		field :scheduled, :type => Boolean

		def getTiming
			self.timing
		end

		def getDocsOwner
			self.docsOwner
		end

		def getAdmin
			self.admin
		end

		def schedule
			self.scheduled = true
			save
		end

		def unschedule
			self.scheduled = false
			save
		end

		def scheduled?
			self.scheduled
		end

	end
end