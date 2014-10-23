require 'google/api_client'

class ServiceAccount
	P12 = "WATCHDOG-122d396cea06.p12"
	MAIL = "867950402393-r4chltcopuocui2abrlv1u2ph1h477a7@developer.gserviceaccount.com"
	def initialize
		keyFile = File.read(File.join(File.dirname(__FILE__), P12))
		key = Google::APIClient::PKCS12.load_key(keyFile, 'notasecret')
		@service_account = Google::APIClient::JWTAsserter.new(
		    MAIL,
		    ['https://www.googleapis.com/auth/admin.directory.user', 'https://www.googleapis.com/auth/drive'],
		    key)
	end

	def authorize(userEmail = nil)
		p "authorize: " + userEmail unless userEmail.nil?
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