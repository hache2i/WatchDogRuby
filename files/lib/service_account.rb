require 'google/api_client'

class ServiceAccount
	P12 = "WATCHDOG-25642ef8c382.p12"
	MAIL = "867950402393-nqa73qd0dh9u3g71pl25jpd3abeeg3sl@developer.gserviceaccount.com"
	# P12 = "API-Project-6f4a3c23ba4d.p12"
	# MAIL = "95351256687-0mmci6rtdlslqv839l8ah7f3fqp10qu4@developer.gserviceaccount.com"
	def initialize
		keyFile = File.read(File.join(File.dirname(__FILE__), P12))
		key = Google::APIClient::PKCS12.load_key(keyFile, 'notasecret')
		@service_account = Google::APIClient::JWTAsserter.new(
		    MAIL,
		    ['https://www.googleapis.com/auth/admin.directory.user', 'https://www.googleapis.com/auth/drive'],
		    key)
	end

	def authorize(userEmail = nil)
		begin
			return @service_account.authorize(userEmail) if !userEmail.nil?
			return @service_account.authorize if userEmail.nil?
		rescue
			puts 'exception authorizing ' + userEmail + '... retrying' if !userEmail.nil?
			return @service_account.authorize(userEmail) if !userEmail.nil?
			return @service_account.authorize if userEmail.nil?
		end
	end
end