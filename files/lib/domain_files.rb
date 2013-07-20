module Files
	class DomainFiles
		def initialize
			@usersFiles = []
		end

		def add(aUserFiles)
			@usersFiles << aUserFiles
		end

		def to_a
			files = []
			@usersFiles.each do |userFiles|
				files.concat userFiles.getFiles
			end
			files
		end

		def to_s
			notEmptyUsersFiles = @usersFiles.find_all{|userFiles| !userFiles.empty?}
			notEmptyUsersFiles.map{|userFiles| userFiles.to_s}.join('-')
		end

	end
end