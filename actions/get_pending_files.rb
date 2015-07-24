require_relative '../wddomain/lib/watchdog_domain'

module Wd
    module Actions
        class GetPendingFiles

            def self.do from, users, access_data
                users = Watchdog::Global::Watchdog.getUsers access_data[:userEmail], access_data[:domain] if users.nil?
                users_emails = users.map(&:email)
                proposed_change_files = Files::Changed.pending_for_users users_emails, from
                proposed_change_files
            end

        end
    end
end