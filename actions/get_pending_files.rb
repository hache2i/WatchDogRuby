require_relative '../wddomain/lib/watchdog_domain'

module Wd
    module Actions
        class GetPendingFiles

            def self.do from, filter, access_data
                users = Files::Changed.users(access_data[:domain]) if filter.nil?
                users = filter["oldOwner"] unless filter.nil?
                # if filter.nil?
                #     p "with users"
                #     users = Watchdog::Global::Watchdog.getUsers access_data[:userEmail], access_data[:domain] if users.nil?
                #     users_emails = users.map(&:email)
                    proposed_change_files = Files::Changed.pending_for_users users, from
                # else
                #     p "with filter"
                #     filter = {} if filter.nil?
                #     proposed_change_files = Files::Changed.where(domain: access_data[:domain]).in("oldOwner" => filter["oldOwner"]).limit(50).skip(from).desc(:created_at)
                # end
                proposed_change_files
            end

        end
    end
end