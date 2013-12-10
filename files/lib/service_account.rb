require 'google/api_client'

class ServiceAccount
	def initialize
		keyFile = File.read(File.join(File.dirname(__FILE__), '5b198e954f9735c6cbc2c28dfe79b9cf8c90e909-privatekey.p12'))
		key = Google::APIClient::PKCS12.load_key(keyFile, 'notasecret')
		@service_account = Google::APIClient::JWTAsserter.new(
		    '622425308764-du41u0dqopb3eja3ei9s2q4v30mihuie@developer.gserviceaccount.com',
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