class LogRecord
	attr_accessor :message, :domain, :user, :when, :level
	def initialize(message, domain, user, level = nil)
		@message = message
		@domain = domain
		@user = user
		@when = Time.now
		@level = :info
		@level = level unless level.nil?
	end
end