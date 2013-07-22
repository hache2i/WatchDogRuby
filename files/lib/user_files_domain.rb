require_relative 'user_files'
require_relative 'drive_file'

module Files
	class UserFilesDomain
		def initialize(aServiceAccount, aClient, aDrive, aUser)
			@client = aClient
			@drive = aDrive
			@user = aUser
			@client.authorization = aServiceAccount.authorize(@user)
			@privateFolder = findPrivateFolder
		end

		def getUserFiles
			userFiles = UserFiles.new @user
			begin
				result = @client.execute(:api_method => @drive.files.list, :parameters => assembleParams(getPageToken(result)))
				items = result.data.items
				nonPrivateItems = items.find_all{|item| !isPrivate(item['id'])}
				userFiles.addFiles(nonPrivateItems.map{|item| DriveFile.new(item['id'], item['title'], item['ownerNames'])})
			end while hasNextPage? result
			userFiles
		end

		def findPrivateFolder
			userFiles = UserFiles.new @user
			result = @client.execute(:api_method => @drive.files.list, :parameters => {'q' => "'" + @user + "' in owners and title = 'Private' and mimeType = 'application/vnd.google-apps.folder'"})

			raise MoreThanOnePrivateFolderException if result.data.items.length > 1
			return nil if result.data.items.length == 0
			
			item = result.data.items[0]
			privateFolder = DriveFile.new(item['id'], item['title'], item['ownerNames'])
			privateFolder
		end

		def assembleParams(pageToken)
			params = {'q' => "'" + @user + "' in owners "}
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

		def isPrivate(file_id)
			return false if @privateFolder.nil?
			isPrivateFolder(file_id) || fileInFolder(file_id, @privateFolder.id) || fileInChildrenFolders(file_id, @privateFolder.id)
		end

		def isPrivateFolder(fileId)
			fileId == @privateFolder.id
		end

		def fileInChildrenFolders(file_id, folder_id)
		  result = @client.execute(
		    :api_method => @drive.files.list,
		    :parameters => { 'q' => "mimeType = 'application/vnd.google-apps.folder'" })
		  items = result.data.items
		  under = false
		  items.each do |item|
		  	under ||= fileInFolder(file_id, item['id'])
		  end
		  under
		end

		def fileInFolder(file_id, folder_id)
		  result = @client.execute(
		    :api_method => @drive.children.get,
		    :parameters => { 'folderId' => folder_id, 'childId' => file_id })
		  if result.status == 200
		    return true
		  elsif result.status == 404
		    return false
		  else
		    puts "An error occurred: #{result.data['error']['message']}"
		  end
		end
	end
end