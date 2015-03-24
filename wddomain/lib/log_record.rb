class LogRecord
	attr_accessor :message, :domain, :user, :when, :level
	def initialize(message, domain, user, level = nil)
		@message = message
		@domain = domain
		@user = user
		@when = DateTime.now.strftime('%Q')
		@level = :info
		@level = level unless level.nil?
	end

	def to_hash
		aux = {}
		aux.merge! message: @message
		aux.merge! domain: @domain
		aux.merge! user: @user
		aux.merge! level: @level
		aux.merge! when: @when
		aux
	end
end