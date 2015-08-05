require_relative 'files_filter'

module Wd
  module Actions
    class GetFilesCount

      def self.do domain, filter
        mongo_filter = FilesFilter.to_mongo filter, domain
        count = Files::Changed.in(mongo_filter[:in]).where(mongo_filter[:where]).count
        { count: count }
      end

    end
  end
end