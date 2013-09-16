require 'mongoid'

module WDAdmin

	class DomainStatus

		include Mongoid::Document

		field :domain, :type => String
		field :active, :type => Boolean

	end
end