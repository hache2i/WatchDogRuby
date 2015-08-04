module Wd
    module Actions
        class GetFiles

            def self.do from, filter, access_data
                in_filter = {}
                in_filter.merge!(oldOwner: filter[:oldOwner]) unless filter.nil? || filter[:oldOwner].nil?

                mongo_filter = {}
                mongo_filter.merge!(pending: filter[:pending]) unless filter.nil? || filter[:pending].nil?
                mongo_filter.merge!(domain: access_data[:domain])

                files = Files::Changed.in(in_filter).where(mongo_filter).limit(50).skip(from).desc(:created_at)
                files
            end

        end
    end
end