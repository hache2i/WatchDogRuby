require_relative "../files/lib/changed"
require_relative "../files/lib/drive_connection"
require_relative "../files/lib/user_files_domain"

module Wd
    module Actions
        class ChangePendingFile
            def self.do pendingId, domain
                p "pending id: #{pendingId} for domain: #{domain}"
                pendingFile = Files::Changed.find(pendingId)
                userFilesDomain = Files::UserFilesDomain.new Files::DriveConnection.new, pendingFile.oldOwner, domain
                userFilesDomain.changeFilePermission pendingFile
            end
        end
    end
end