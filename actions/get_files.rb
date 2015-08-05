require_relative 'files_filter'

module Wd
    module Actions
        class GetFiles

            def self.do from, filter, access_data
                mongo_filter = FilesFilter.to_mongo filter, access_data[:domain]
                files = Files::Changed.in(mongo_filter[:in]).where(mongo_filter[:where]).limit(50).skip(from).desc(:created_at)
                files
            end

        end
    end
end