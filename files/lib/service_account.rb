require 'google/api_client'

class ServiceAccount
	def initialize(keyFile)
		key = Google::APIClient::PKCS12.load_key(keyFile, 'notasecret')
		@service_account = Google::APIClient::JWTAsserter.new(
		    '111623891942@developer.gserviceaccount.com',
		    'https://www.googleapis.com/auth/drive',
		    key)
	end

	def authorize(userEmail = nil)
		return @service_account.authorize(userEmail) if !userEmail.nil?
		return @service_account.authorize if userEmail.nil?
	end
end