require 'google/api_client'

require_relative '../../files/lib/service_account'
require_relative 'user'

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
			mails = [];
			begin
				result = @client.execute(
					:api_method => @api.users.list, 
					:parameters => assembleParams(getPageToken(result), customerId))
				raise UsersDomainException if !result.status.eql? 200
				mails.concat(result.data.users.map{|user| User.new(user['primaryEmail'])})
			end while hasNextPage? result
			mails
		end

		def assembleParams(pageToken, customerId)
			params = {'customer' => customerId}
			params.merge!('pageToken' => pageToken) if !pageToken.empty?
			params
		end

		def getPageToken(result)
			return '' if result.nil? || result.data.nil?
			return result.data.next_page_token if hasNextPage? result
			''
		end

		def hasNextPage?(result)
			!result.data.next_page_token.nil? && !result.data.next_page_token.empty?
		end

		def isAdmin(email)
			@client.authorization = @serviceAccount.authorize(email)
			result = @client.execute(
				:api_method => @api.users.get, 
				:parameters => {
					'userKey' => email
				})
			raise UsersDomainException if ![200, 403].include?(result.status)
			!result.data['isAdmin'].nil? && result.data['isAdmin']
		end

		private 

		def getCustomerId(email)
			@client.authorization = @serviceAccount.authorize(email)
			result = @client.execute(
				:api_method => @api.users.get, 
				:parameters => {
					'userKey' => email
				})
			raise UsersDomainException if !result.status.eql? 200
			customerId = result.data['customerId']
		end

	end
end