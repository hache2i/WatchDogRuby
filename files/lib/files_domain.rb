require 'google/api_client'

require_relative 'domain_files'
require_relative 'service_account'
require_relative 'user_files_domain'
require_relative 'more_than_one_private_folder_exception'
require_relative 'user_files_exception'
require_relative 'user_files_to_change'
require_relative 'change_permissions_batcher'
require_relative 'exponential_backoff'

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

		def changePermissions(domainFilesToChange, owner)
			domainFilesToChange.each do |userFilesToChange|
				changeUserFilesPermissions(userFilesToChange, owner) if userFilesToChange.getEmail != owner
  			end
		end

		private 

		def changeUserFilesPermissions(userFilesToChange, owner)
			start = Time.now.to_f

			log = 'changing ' + userFilesToChange.getFiles.length.to_s + " files for " + userFilesToChange.getEmail
			puts log
			userFilesToChange.getFiles.each do |fileId|
				new_permission = getNewPermissionSchema owner
				request = buildRequest(new_permission, fileId)
				result = @client.execute request
				maxRetries = 5
				max = 1
				backoffs = ExponentialBackoff.exp_backoff maxRetries
				while result.status != 200 && max < maxRetries do
					time = backoffs[max - 1]
					puts 'error processing file ' + fileId + '... retrying in ' + time.to_s
					sleep time
					result = @client.execute request
					max += 1
				end
			end

			puts (Time.now.to_f - start).to_s + ' ms'
		end

		# def changeUserFilesPermissions(userFilesToChange, owner)
		# 	start = Time.now.to_f
		# 	batchSize = 10
		# 	log = 'changing ' + userFilesToChange.getFiles.length.to_s + " files for " + userFilesToChange.getEmail
		# 	puts log
		# 	@client.authorization = @serviceAccount.authorize(userFilesToChange.getEmail)
		# 	batcher = ChangePermissionsBatcher.new userFilesToChange.getFiles
		# 	while batcher.shouldNotExit do
		# 		batch = Google::APIClient::BatchRequest.new
		# 		filesIds = batcher.next batchSize
		# 		filesIds.each do |fileId|
		# 			new_permission = getNewPermissionSchema owner
		# 			request = buildRequest(new_permission, fileId)
		# 			batch.add(request) do |result|
		# 				batcher.addFile fileId, result.status if result.status != 200
		# 			end
		# 		end
		# 		@client.execute batch
		# 		puts log + ' - ' + batcher.to_s
		# 	end
		# 	puts (Time.now.to_f - start).to_s + ' ms'
		# end

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
