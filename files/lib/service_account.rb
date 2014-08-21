require 'google/api_client'

class ServiceAccount
	def initialize
		keyFile = File.read(File.join(File.dirname(__FILE__), 'API-Project-6f4a3c23ba4d.p12'))
		key = Google::APIClient::PKCS12.load_key(keyFile, 'notasecret')
		@service_account = Google::APIClient::JWTAsserter.new(
		    '95351256687-0mmci6rtdlslqv839l8ah7f3fqp10qu4@developer.gserviceaccount.com',
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