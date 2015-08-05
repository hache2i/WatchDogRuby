module Wd
  module Actions
    class FilesFilter

      def self.to_mongo filter, domain
        in_filter = {}
        in_filter.merge!(oldOwner: filter[:oldOwner]) unless filter.nil? || filter[:oldOwner].nil?

        mongo_filter = {}
        mongo_filter.merge!(pending: filter[:pending]) unless filter.nil? || filter[:pending].nil?
        mongo_filter.merge!(title: Regexp.new(".*" + filter[:title] + ".*", "i")) unless filter.nil? || filter[:title].nil?
        mongo_filter.merge!(domain: domain)

        { in: in_filter, where: mongo_filter }
      end

      def self.without_owner filter, domain
        mongo_filter = {}
        mongo_filter.merge!(pending: filter[:pending]) unless filter.nil? || filter[:pending].nil?
        mongo_filter.merge!(title: Regexp.new(".*" + filter[:title] + ".*", "i")) unless filter.nil? || filter[:title].nil?
        mongo_filter.merge!(domain: domain)
        mongo_filter
      end

    end
  end
end