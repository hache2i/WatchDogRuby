require_relative 'user_files'
require_relative 'drive_file'
require_relative 'more_than_one_private_folder_exception'

module Files
	class PrivateFolders
		def initialize(aServiceAccount, aDrive, aClient, aUser)
			@serviceAccount = aServiceAccount
			@drive = aDrive
			@client = aClient
			@user = aUser
		end

		def isPrivate(file)
			return false if @privateFoldersIds.empty?
			isPrivate = false
			@privateFoldersIds.each do |privateFolderId|
				isPrivate = isPrivate || privateFolderId == file['id'] || fileInFolder(file, privateFolderId)
			end
			isPrivate
		end

		def load
			@privateFolder = findPrivateFolder
			@privateFoldersIds = []
			@privateFoldersIds << @privateFolder.id if !@privateFolder.nil?
			@privateFoldersIds.concat findPrivateFoldersIds if !@privateFolder.nil?
		end

		private

		def fileInFolder(file, folder_id)
			isIn = false
			file['parents'].each do |parent|
				isIn ||= (parent['id'] == folder_id)
			end
			isIn
		end

		def findPrivateFoldersIds
			result = @client.execute(
				:api_method => @drive.files.list, 
				:parameters => 
				{'q' => "'" + @privateFolder.id + "' in parents and mimeType = 'application/vnd.google-apps.folder'",
					'fields' => 'items(id,ownerNames,title)'
					})
			return [] if !result.status.eql? 200
			result.data.items.map{|item| item['id']}
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

	end
end