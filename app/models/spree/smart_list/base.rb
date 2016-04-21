module Spree
  module SmartList
    class Base

      TIME_FRAME = 1.week

      attr_accessor :time_frame, :list_uid

      def initialize list_uid = nil
        @list_uid = list_uid
      end

      def time_frame
        @time_frame || TIME_FRAME
      end

      def fetch_list_records
        # @list_uid ? MailChimpApi::Call @list_uid || []
      end

      def contacts
        formatted_contacts - fetch_list_records
      end

      def formatted_contacts
        query.pluck(:email)
      end

      def query
        Spree.user_class.all
      end

      def process
        # Spree::List.process_new_list contacts, @list_uid
      end

      def computed_time_frame
        Time.current - time_frame
      end

    end
  end
end
