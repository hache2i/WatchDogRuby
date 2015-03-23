module Wd
	module Actions
		class GetCommonFolders

			def self.do docaccount
				driveConnection = Files::DriveConnection.new
				rootFolders = Files::RootFolders.new driveConnection, docaccount
				folders = rootFolders.get
				{ folders: folders }
			end

		end
	end
end