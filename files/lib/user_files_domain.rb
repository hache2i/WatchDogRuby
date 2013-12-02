require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'
require_relative 'more_than_one_private_folder_exception'

module Files
	class UserFilesDomain
		def initialize(aServiceAccount, aClient, aDrive, aUser)
			@client = aClient
			@drive = aDrive
			@user = aUser
			@client.authorization = aServiceAccount.authorize(@user)
			@privateFolders = PrivateFolders.new(aServiceAccount, @drive, @client, @user)
			@privateFolders.load
		end

		def getUserFiles
			userFiles = UserFiles.new @user
			begin
				result = @client.execute(:api_method => @drive.files.list, :parameters => assembleParams(getPageToken(result)))
				raise UserFilesException if !result.status.eql? 200
				items = result.data.items
				nonPrivateItems = items.find_all{|item| !@privateFolders.isPrivate(item)}
				userFiles.addFiles(nonPrivateItems.map{|item| DriveFile.new(item['id'], item['title'], item['ownerNames'])})
			end while hasNextPage? result
			userFiles
		end

		def assembleParams(pageToken)
			params = {'q' => "'" + @user + "' in owners and trashed = false "}
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

	end
end