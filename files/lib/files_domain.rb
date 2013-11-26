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
			filesToChange.each do |fileToChange|
				changeUserFilesPermissions(fileToChange, owner)
  			end
		end

		private 

		def changeUserFilesPermissions(fileToChange, owner)
			backoff = {:mail => fileToChange[:mail],
				:ids => []}

			batch = Google::APIClient::BatchRequest.new
			puts 'changing ' + fileToChange[:ids].length.to_s + " files for " + fileToChange[:mail]
			@client.authorization = @serviceAccount.authorize(fileToChange[:mail])
			fileToChange[:ids].each do |fileId|
				new_permission = getNewPermissionSchema owner
				request = buildRequest(new_permission, fileId)
				batch.add(request) do |result|
					backoff[:ids] << fileId if result.status != 200
				end
			end
			@client.execute batch
			changeUserFilesPermissions(backoff, owner) if !backoff[:ids].empty?
		end

		def getUserFiles(user)
			begin
				userFilesDomain = UserFilesDomain.new(@serviceAccount, @client, @drive, user)
				userFilesDomain.getUserFiles
			rescue UserFilesException => e
				puts "Error while getting files from user " + user + "!!!"
				[]
			rescue MoreThanOnePrivateFolderException => e
				puts "Found more than one private folder for user " + user + "!!!"
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
