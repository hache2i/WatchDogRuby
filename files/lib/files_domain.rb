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
			mails = []
			filesToChange.each do |fileToChange|
				mails << fileToChange[:mail] if !mails.include?(fileToChange[:mail])
				@client.authorization = @serviceAccount.authorize(fileToChange[:mail])
				fileToChange[:ids].each do |id|
					new_permission = @drive.permissions.insert.request_schema.new({
						'value' => owner,
						'type' => 'user',
						'role' => 'owner'
					})
					result = @client.execute(
						:api_method => @drive.permissions.insert,
						:body_object => new_permission,
						:parameters => { 'fileId' => id })
					if result.status != 200
						puts result.status 
					end
				end
  			end
  			puts mails
  			getFiles(mails)
		end

	end
end
