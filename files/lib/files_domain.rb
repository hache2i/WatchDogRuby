require 'google/api_client'

require_relative 'domain_files'
require_relative 'service_account'
require_relative 'user_files_domain'
require_relative 'more_than_one_private_folder_exception'
require_relative 'private_folder_hierarchy_exception'
require_relative 'user_files_exception'
require_relative 'user_files_to_change'
require_relative 'drive_api_helper'

module Files
	class FilesDomain

		def initialize executionLog, driveConnection
			@executionLog = executionLog
			@driveConnection = driveConnection
		end

		def getFiles(users)
			domainFiles = DomainFiles.new
			users.each do |user|
				userFiles = getUserFiles(user)
				domainFiles.add userFiles
				p user + " - " + userFiles.length.to_s
			end
			domainFiles
		end

		def findFilesToRetrieveOwnership(users, currentOwner)
			domainFiles = DomainFiles.new
			users.each do |user|
				userFilesDomain = UserFilesDomain.new(@driveConnection, user)
				userFiles = userFilesDomain.getMyOldOwn currentOwner
				domainFiles.add userFiles
				p user + " - " + userFiles.length.to_s
			end
			domainFiles
		end

		def giveOwnershipBack(domainFilesToChange, currentOwner)
			domainFilesToChange.each do |userFilesToChange|
				user = currentOwner
				userFilesDomain = UserFilesDomain.new @driveConnection, user
				userFilesDomain.changeUserFilesPermissions userFilesToChange.getFiles, userFilesToChange.getEmail
			end
		end

		def fixRoot users
			users.each do |user|
				userFilesDomain = UserFilesDomain.new(@driveConnection, user)
				userFilesDomain.fixRoot
			end
		end

		def unshare users, withWho
			users.each do |user|
				p "unsharing files for " + user
				userFilesDomain = UserFilesDomain.new(@driveConnection, user)
				userFilesDomain.unshare withWho
			end
		end

		def changePermissions(domainFilesToChange, owner)
			domainFilesToChange.each do |userFilesToChange|
				user = userFilesToChange.getEmail
				userFilesDomain = UserFilesDomain.new @driveConnection, user
				if user != owner
					userFilesDomain.changeUserFilesPermissions userFilesToChange.getFiles, owner
				end
			end
		end

		private 

		def getUserFiles(user)
			begin
				userFilesDomain = UserFilesDomain.new(@driveConnection, user)
				userFilesDomain.getUserFiles
			rescue UserFilesException => e
				puts "Error while getting files from user " + user + "!!!"
				[]
			rescue MoreThanOnePrivateFolderException => e
				puts "Found more than one private folder for user " + user + "!!!"
				[]
			rescue PrivateFolderHierarchyException => e
				puts "Unable to get private folder hierarchy for user " + user + "!!!"
				[]
			end
		end

		def extractDomain(email)
			email.scan(/(.+)@(.+)/)[0][1]
		end

	end
end
