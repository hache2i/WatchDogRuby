module Wd
  module Actions
    class GetFilesCount

      def self.do domain, filter
        in_filter = {}
        in_filter.merge!(oldOwner: filter[:oldOwner]) unless filter.nil? || filter[:oldOwner].nil?

        mongo_filter = {}
        mongo_filter.merge!(pending: filter[:pending]) unless filter.nil? || filter[:pending].nil?
        mongo_filter.merge!(domain: domain)

        count = Files::Changed.in(in_filter).where(mongo_filter).count
        { count: count }
      end

    end
  end
end