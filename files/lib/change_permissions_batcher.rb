module Files
	class ChangePermissionsBatcher
		def initialize aList
			@list = aList.dup
			@failed = 0
		end

		def next howMany
			@failed = 0
			@list.pop howMany
		end

		def hasElements?
			!@list.empty?
		end

		def remaining
			return 0 if @list.empty?
			@list.length
		end

		def addFile fileId
			@list.push fileId
			@failed += 1
		end

		def to_s
			remaining.to_s + ' remaining - ' + @failed.to_s + ' failed'
		end
	end
end