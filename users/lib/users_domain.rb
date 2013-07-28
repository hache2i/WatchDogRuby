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
			result = @client.execute(
				:api_method => @api.users.list, 
				:parameters => {
					'domain' => extractDomain(email)
				})
			result.data.users.map{|user| user['primaryEmail']}
		end

		private 

		def extractDomain(email)
			email.scan(/(.+)@(.+)/)[0][1]
		end

	end
end