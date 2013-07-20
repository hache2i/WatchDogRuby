module Files
	class DriveFile
		attr_accessor :id, :title, :owners
		def initialize(aId, aTitle, aOwnerNames)
			@id = aId
			@title = aTitle
			@owners = aOwnerNames.join(', ')
		end
	end
end