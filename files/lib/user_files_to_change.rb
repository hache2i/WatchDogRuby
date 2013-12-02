module Files
	class UserFilesToChange
		def initialize email
			@email = email
			@files = []
		end

		def getEmail
			@email
		end

		def getFiles
			@files
		end

		def addFile fileId
			@files << fileId
		end

		def addFiles filesIds
			@files.concat filesIds
		end
	end
end