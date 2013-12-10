module Files
	class ChangePermissionsBatcher
		def initialize aList
			@list = aList.dup
			@failed = 0
			@errors = {}
			@criticalError = false
		end

		def next howMany
			@failed = 0
			@errors = {}
			@list.pop howMany
		end

		def hasElements?
			!@list.empty?
		end

		def remaining
			return 0 if @list.empty?
			@list.length
		end

		def addFile(fileId, errorStatus)
			@list.push fileId if errorStatus == 500
			@criticalError = true if errorStatus == 401
			@failed += 1
			@errors[errorStatus] = 0 if @errors[errorStatus].nil?
			@errors[errorStatus] += 1 if !@errors[errorStatus].nil?
		end

		def shouldNotExit
			!@criticalError && hasElements?
		end

		def to_s
			remaining.to_s + ' remaining - ' + @failed.to_s + ' failed (' + errors_to_s + ')'
		end

		def errors_to_s
			errorsStr = ''
			@errors.each do |status, count|
				errorsStr += count.to_s + '/' + status.to_s
			end
			errorsStr
		end
	end
end