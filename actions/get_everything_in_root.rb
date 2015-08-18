require_relative '../files/lib/everything_in_root'

module Wd
  module Actions
    class GetEverythingInRoot

      def self.do docaccount
        driveConnection = Files::DriveConnection.new
        rootFolders = Files::EverythingInRoot.new driveConnection, docaccount
        folders = rootFolders.get
        { folders: folders }
      end

    end
  end
end