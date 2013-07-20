module Files
	class FilesToChange
		def self.unmarshall(str)
			result = []
			userMailAndIdsStr = str.split('&')
			userMailAndIdsStr.each do |item|
				userMailAndIds = item.split('#')
				user = userMailAndIds[0]
				ids = userMailAndIds[1].split(',')
				result << {:mail => user, :ids => ids}
			end
			result
		end
	end
end