module Wd
    module Actions
        class GetUsersWithPendingFiles

            def self.do access_data
                Files::Changed.users access_data[:domain]
            end

        end
    end
end