require 'mongoid'

module WDAdmin

	class DomainStatus

		include Mongoid::Document

		field :domain, :type => String
		field :active, :type => Boolean
		field :licenses, :type => Integer

	end
end