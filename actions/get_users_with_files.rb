module Wd
    module Actions
        class GetUsersWithFiles

            def self.do access_data, filter
                mongo_filter = {}
                mongo_filter.merge!(domain: access_data[:domain])
                mongo_filter.merge!(pending: filter[:pending]) unless filter.nil? || filter[:pending].nil?

                Files::Changed.where(mongo_filter).distinct(:oldOwner)
            end

        end
    end
end