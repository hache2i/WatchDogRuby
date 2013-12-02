require_relative 'user_files_to_change'

module Files
	class FilesToChange
		def self.unmarshall(str)
			result = []
			userMailAndIdsStr = str.split('&')
			userMailAndIdsStr.each do |item|
				userMailAndIds = item.split('#')
				user = userMailAndIds[0]
				ids = userMailAndIds[1].split(',')
				userFilesToChange = UserFilesToChange.new user
				userFilesToChange.addFiles ids
				result << userFilesToChange
			end
			result
		end
	end
end