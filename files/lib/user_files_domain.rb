require_relative 'user_files'
require_relative 'drive_file'
require_relative 'private_folders'
require_relative 'changed'

module Files
	class UserFilesDomain
		def initialize aDriveConnection, aUser, aDomain
			@domain = aDomain
			@user = aUser

			@driveConnection = aDriveConnection
			@driveConnection.authorize @user

			@privateFolders = PrivateFolders.new @driveConnection, @user
			@privateFolders.load
		end

		def changeUserFilesPermissions(files, owner)
			files.each do |file|
				new_owner_permission = DriveApiHelper.get_current_permission_for @driveConnection, owner, file["id"]
				new_owner_permission.role = "owner"
				api_result = DriveApiHelper.update_permission @driveConnection, file["id"], new_owner_permission
				if api_result.status == 200
					Changed.create changed @user, owner, file, @domain
				end
			end
		end

		def changed currentOwner, newOwner, fileData, domain
			{
				:fileId => fileData["id"],
				:oldOwner => currentOwner,
				:newOwner => newOwner,
				:parentId => fileData["parent"],
				:title => fileData["title"],
				:domain => domain
			}
		end

		def unshare withWho
			userFiles = UserFiles.new @user
			begin
				result = DriveApiHelper.list_files @driveConnection, assembleParamsMyFiles(getPageToken(result))
				raise UserFilesException if !result.status.eql? 200
				items = result.data.items
				items.each do |item|
					api_result = DriveApiHelper.list_permissions @driveConnection, { 'fileId' => item['id'] }
				  if api_result.status == 200
				    permissions = api_result.data
				    bla = permissions.items.find_all{|item| item['emailAddress'] == 'documentation@watchdog.h2itec.com' }
				    bla.each do |permission|
				    	unshare_result = DriveApiHelper.delete_permission @driveConnection, item['id'], permission['id']
						  if unshare_result.status != 204
						    puts "An error occurred: #{result.data}"
						  end
				    end
				  else
				    puts "An error occurred: #{result.data['error']['message']}"
				  end
				end
			end while hasNextPage? result
		end

		def getUserFiles
			userFiles = UserFiles.new @user
			begin
				result = DriveApiHelper.list_files @driveConnection, assembleParamsMyFiles(getPageToken(result))
				raise UserFilesException if !result.status.eql? 200
				items = result.data.items
				nonPrivateItems = items.find_all{|item| !@privateFolders.isPrivate(item) }
				userFiles.addFiles(nonPrivateItems.map{|item| DriveFile.new(item['id'], item['title'], item['ownerNames'])})
			end while hasNextPage? result
			userFiles
		end

		def getMyOldOwn currentOwner
			userFiles = UserFiles.new @user
			begin
				result = DriveApiHelper.list_files @driveConnection, assembleParamsSharedWithMe(getPageToken(result), currentOwner)
				raise UserFilesException if !result.status.eql? 200
				items = result.data.items
				myOldOwn = items.find_all{|item| item['sharingUser']['emailAddress'] == @user }
				userFiles.addFiles(myOldOwn.map{|item| DriveFile.new(item['id'], item['title'], item['ownerNames'])})
			end while hasNextPage? result
			userFiles
		end

		def fixRoot
			p "fixing root folder for " + @user
			userFiles = UserFiles.new @user
			begin
				result = DriveApiHelper.list_files @driveConnection, assembleParamsMyFiles(getPageToken(result))
				raise UserFilesException if !result.status.eql? 200
				items = result.data.items
				items.each do |item|
					if item['parents'].length > 1
						roots = item['parents'].select{ |parent| parent['isRoot'] }
						p "parent iddddd " + roots.first['id']
						deleteFromRoot item['id'], roots.first['id']
					end
				end
			end while hasNextPage? result
		end

		def deleteFromRoot file_id, folder_id
		  result = DriveApiHelper.remove_parent @driveConnection, file_id, folder_id
		  if result.status != 204
		    puts "An error occurred: #{result.data}"
		  end
		end

		def assembleParamsSharedWithMe(pageToken, currentOwner)
			params = {'q' => "sharedWithMe and trashed = false and '" + currentOwner + "' in owners"}
			params.merge!('pageToken' => pageToken) if !pageToken.empty?
			params
		end

		def assembleParamsMyFiles(pageToken)
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