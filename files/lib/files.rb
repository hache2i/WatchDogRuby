module Files
	class Files
		def initialize
			@files = []
		end

		def add(file)
			@files << file
		end

		def addAll(aFiles)
			@files.concat(aFiles.to_a)
		end

		def length
			@files.length
		end

		def empty?
			@files.empty?
		end
		
		def to_a
			@files
		end

		def to_s
			@files.map(&:id).join(',')
		end
	end
end