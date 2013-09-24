require 'google/api_client'

require_relative 'domain_files'
require_relative 'service_account'
require_relative 'user_files_domain'
require_relative 'more_than_one_private_folder_exception'
require_relative 'user_files_exception'

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
				domainFiles.add getUserFiles(user)
			end
			domainFiles
		end

		def changePermissions(filesToChange, owner)
			changed = 0
			filesToChange.each do |fileToChange|
				changed += changeUserFilesPermissions(fileToChange, owner)
  			end
  			changed
		end

		private 

		def changeUserFilesPermissions(fileToChange, owner)
			changed = 0
			batch = Google::APIClient::BatchRequest.new
			@client.authorization = @serviceAccount.authorize(fileToChange[:mail])
			fileToChange[:ids].each do |fileId|
				new_permission = getNewPermissionSchema owner
				request = buildRequest(new_permission, fileId)
				batch.add(request) do |result|
					changed = manageResult(result, changed)
				end
			end
			@client.execute batch
			changed
		end

		def getUserFiles(user)
			begin
				userFilesDomain = UserFilesDomain.new(@serviceAccount, @client, @drive, user)
				userFilesDomain.getUserFiles
			rescue UserFilesException => e
				puts "Error while getting files from user " + user + "!!!"
				[]
			rescue MoreThanOnePrivateFolderException => e
				[]
			end
		end

		def manageResult(result, changed)
			if result.status == 200
				changed += 1
			end
			if result.status != 200
				puts result.status 
			end
			changed
		end

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
