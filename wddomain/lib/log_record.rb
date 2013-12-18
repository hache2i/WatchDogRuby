class LogRecord
	attr_accessor :message, :domain, :user, :when
	def initialize(message, domain, user)
		@message = message
		@domain = domain
		@user = user
		@when = Time.now
	end
end