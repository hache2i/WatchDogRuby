require 'google/api_client'

require_relative 'domain_files'
require_relative 'service_account'
require_relative 'user_files_domain'
require_relative 'more_than_one_private_folder_exception'

module Files
	class FilesDomain

		def initialize
			@serviceAccount = ServiceAccount.new
			@client = Google::APIClient.new
			@drive = @client.discovered_api('drive', 'v2')
		end

		def getFiles(users)
			domainFiles = DomainFiles.new
			users.each do |user|
				begin
					userFilesDomain = UserFilesDomain.new(@serviceAccount, @client, @drive, user)
					domainFiles.add(userFilesDomain.getUserFiles)
				rescue MoreThanOnePrivateFolderException => e
				end
			end
			domainFiles
		end

		def changePermissions(filesToChange, owner)
			changed = 0
			filesToChange.each do |fileToChange|
				batch = Google::APIClient::BatchRequest.new do |result|
				end
				@client.authorization = @serviceAccount.authorize(fileToChange[:mail])
				fileToChange[:ids].each do |fileId|
					new_permission = getNewPermissionSchema owner
					request = buildRequest(new_permission, fileId)
					batch.add(request) do |result|
						if result.status == 200
							changed += 1
						end
						if result.status != 200
							puts result.status 
						end
					end
				end
				@client.execute batch
  			end
  			changed
		end

		private 

		def buildRequest(newPermission, fileId)
			{
				:api_method => @drive.permissions.insert,
				:body_object => newPermission,
				:parameters => { 'fileId' => fileId }
			}
		end

		def getNewPermissionSchema(owner)
			@drive.permissions.insert.request_schema.new({
						'value' => owner,
						'type' => 'user',
						'role' => 'owner'
					})
		end

	end
end
