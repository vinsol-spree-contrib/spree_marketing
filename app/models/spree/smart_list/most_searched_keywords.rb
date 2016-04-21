module Spree
  module SmartList
    class MostSearchedKeyword < Base

      def initialize searched_keyword, list_uid = nil
        @list_uid = list_uid
        @time_frame = 1.month
        @searched_keyword = searched_keyword
      end

      def query
        Spree::PageEvent.includes(:actor)
                        .where(search_keywords: @searched_keyword)
                        .where("created_at >= :time_frame", time_frame: computed_time_frame)
                        .where.not(actor_id: nil)
                        .where(actor_type: Spree.user_class)
                        .group(:actor_id)
                        .having("COUNT(spree_page_events.id) > ?", 5)
                        .map { |page_event| page_event.actor }
      end

    end
  end
end
