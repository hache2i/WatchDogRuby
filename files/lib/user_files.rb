require_relative 'files'

module Files
	class UserFiles
		def initialize(aUser)
			@user = aUser
			@files = Files.new
		end

		def getUser
			@user
		end

		def addFiles(files)
			@files.addAll files
		end

		def getFiles
			@files.to_a
		end

		def length
			@files.length
		end

		def empty?
			@files.empty?
		end

		def to_a
			@files.to_a
		end

		def to_s
			return '' if @files.empty?
			str = @user
			str += '#'
			str += @files.to_s
		end

	end
end