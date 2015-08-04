module Watchdog
  module Global
    module Threads
      extend self

      def add thr
        list << thr
      end

      def get
        list
      end

      private 

      def list
        @threads ||= []
      end

    end
  end
end
