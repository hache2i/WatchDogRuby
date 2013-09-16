require 'google/api_client'

require_relative '../../files/lib/service_account'

module Users
	class UsersDomain
		def initialize
			@serviceAccount = ServiceAccount.new
			@client = Google::APIClient.new
			@api = @client.discovered_api('admin', 'directory_v1')
		end

		def getUsers(email)
			@client.authorization = @serviceAccount.authorize(email)
			customerId = getCustomerId email
			result = @client.execute(
				:api_method => @api.users.list, 
				:parameters => {
					'customer' => customerId
				})
			result.data.users.map{|user| user['primaryEmail']}
		end

		def isAdmin(email)
			@client.authorization = @serviceAccount.authorize(email)
			user = @client.execute(
				:api_method => @api.users.get, 
				:parameters => {
					'userKey' => email
				})
			!user.data['isAdmin'].nil? && user.data['isAdmin']
		end

		private 

		def getCustomerId(email)
			@client.authorization = @serviceAccount.authorize(email)
			user = @client.execute(
				:api_method => @api.users.get, 
				:parameters => {
					'userKey' => email
				})
			customerId = user.data['customerId']
		end

		def extractDomain(email)
			email.scan(/(.+)@(.+)/)[0][1]
		end

	end
end