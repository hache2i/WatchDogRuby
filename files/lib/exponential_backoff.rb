class ExponentialBackoff
	def self.exp_backoff(upto)
		result = [ ]
		(1..upto).each do |iter|
			result << ((2.0**iter) + (rand(1001.0) / 1000.0))
		end
		return result
	end
end

      # counter = userFilesToChange.getFiles.length
      # userFilesToChange.getFiles.each do |fileId|
      #   new_permission = getNewPermissionSchema owner
      #   request = buildRequest(new_permission, fileId)
      #   result = @client.execute request
      #   maxRetries = 5
      #   max = 1
      #   backoffs = ExponentialBackoff.exp_backoff maxRetries
      #   while result.status != 200 && max < maxRetries do
      #     p result.status
      #     time = backoffs[max - 1]
      #     puts 'error processing file ' + fileId + '... retrying in ' + time.to_s
      #     sleep time
      #     result = @client.execute request
      #     max += 1
      #   end
      #   p counter.to_s + " - final result " + result.status.to_s
      #   counter -= 1
      # end

