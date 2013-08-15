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
				files.concat userFiles.to_a
			end
			files
		end

		def to_s
			notEmptyUsersFiles = @usersFiles.find_all{|userFiles| !userFiles.empty?}
			notEmptyUsersFiles.map{|userFiles| userFiles.to_s}.join('&')
		end

		def length
			to_a.length
		end

	end
end