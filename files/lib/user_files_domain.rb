require_relative 'user_files'
require_relative 'drive_file'
require_relative 'more_than_one_private_folder_exception'

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
				raise UserFilesException if !result.status.eql? 200
				items = result.data.items
				nonPrivateItems = items.find_all{|item| !isPrivate(item)}
				userFiles.addFiles(nonPrivateItems.map{|item| DriveFile.new(item['id'], item['title'], item['ownerNames'])})
			end while hasNextPage? result
			userFiles
		end

		def findPrivateFolder
			userFiles = UserFiles.new @user
			result = @client.execute(
				:api_method => @drive.files.list, 
				:parameters => 
				{'q' => "'" + @user + "' in owners and (title = 'Private' or title = 'private' or title = 'PRIVATE') and mimeType = 'application/vnd.google-apps.folder'",
					'fields' => 'items(id,ownerNames,title)'
					})

			raise MoreThanOnePrivateFolderException if result.data.items.length > 1
			return nil if result.data.items.length == 0
			
			item = result.data.items[0]
			privateFolder = DriveFile.new(item['id'], item['title'], item['ownerNames'])
			privateFolder
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

		def isPrivate(file)
			return false if @privateFolder.nil?
			isPrivateFolder(file['id']) || fileInFolder(file, @privateFolder.id) || fileInChildrenFolders(file, @privateFolder.id)
		end

		def isPrivateFolder(fileId)
			fileId == @privateFolder.id
		end

		def fileInChildrenFolders(file, folder_id)
			privateFoldersIds = getChildrenFolders(folder_id)
			under = false
			privateFoldersIds.each do |privateFolderId|
				under ||= fileInFolder(file, privateFolderId)
			end
			under
		end

		def getChildrenFolders(folder_id, folders = nil)
			folders = folders || []
			result = @client.execute(
				:api_method => @drive.children.list,
				:parameters => { 'folderId' => folder_id, 'q' => "mimeType = 'application/vnd.google-apps.folder' " })
			levelFoldersIds = result.data.items.map{|folder| folder['id']}
			folders.concat levelFoldersIds
			levelFoldersIds.each do |folder_id|
				getChildrenFolders(folder_id, folders)
			end
			folders
		end

		def fileInFolder(file, folder_id)
			isIn = false
			file['parents'].each do |parent|
				isIn ||= parent['id'] == folder_id
			end
			isIn
		end

		# def fileInFolder(file, folder_id)
		# 	result = @client.execute(
		# 		:api_method => @drive.children.get,
		# 		:parameters => { 'folderId' => folder_id, 'childId' => file_id })
		# 	if result.status == 200
		# 		return true
		# 	elsif result.status == 404
		# 		return false
		# 	else
		# 		puts "An error occurred: #{result.data['error']['message']}"
		# 	end
		# end
	end
end