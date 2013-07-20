require 'google/api_client'

require_relative 'domain_files'
require_relative 'user_files'
require_relative 'drive_file'
require_relative 'service_account'

module Files
	class FilesDomain

		def initialize(aServiceAccount = nil)
			@serviceAccount = ServiceAccount.new(File.read(File.join(File.dirname(__FILE__), 'cf04d56820828c258d8d45c837e520bdb61f8213-privatekey.p12'))) if aServiceAccount.nil?
			@client = Google::APIClient.new
			@drive = @client.discovered_api('drive', 'v2')
		end

		def getFiles(users)
			domainFiles = DomainFiles.new
			users.each do |user|
			  domainFiles.add(getUserFiles(user))
			end
			domainFiles
		end

		def getUserFiles(user)
			@client.authorization = @serviceAccount.authorize(user)
			userFiles = UserFiles.new user
			begin
				result = @client.execute(:api_method => @drive.files.list, :parameters => assembleParams(user, getPageToken(result)))
				userFiles.addFiles(result.data.items.map{|item| DriveFile.new(item['id'], item['title'], item['ownerNames'])})
			end while hasNextPage? result
			userFiles
		end

		def assembleParams(user, pageToken)
			params = {'q' => "'" + user + "' in owners "}
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

		def changePermissions(filesToChange, owner)
			filesToChange.each do |fileToChange|
				@client.authorization = @serviceAccount.authorize(fileToChange[:mail])
				new_permission = @drive.permissions.insert.request_schema.new({
					'value' => owner,
					'type' => 'user',
					'role' => 'owner'
				})
				result = @client.execute(
					:api_method => @drive.permissions.insert,
					:body_object => new_permission,
					:parameters => { 'fileId' => fileToChange[:id] })
				puts result.status
				# if result.status == 200
				# 	return result.data
				# else
				# 	puts "An error occurred: #{result.data['error']['message']}"
				# end
  			end
  			getUserFiles(owner)
		end
	end
end
