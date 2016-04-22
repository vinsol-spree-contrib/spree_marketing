module Spree
  module Marketing
    class MostSearchedKeywordList < List

      # Constants
      TIME_FRAME = 1.month
      MOST_SEARCHRD_KEYWORD_COUNT = 5

      attr_accessor :searched_keyword

      def user_ids
        Spree::PageEvent.where(search_keywords: searched_keyword)
                        .where("created_at >= :time_frame", time_frame: computed_time)
                        .of_registered_users
                        .where(actor_type: Spree.user_class)
                        .group(:actor_id)
                        .pluck(:actor_id)
      end

      def self.generate
        data.each do |searched_keyword|
          new(searched_keyword: searched_keyword).generate self.class.humanize + searched_keyword
        end
      end

      def self.data
        Spree::PageEvent.where(action: "search")
                        .group(:search_keywords)
                        .order("COUNT(spree_page_events.id) DESC")
                        .limit(MOST_SEARCHRD_KEYWORD_COUNT)
                        .pluck(:search_keywords)
      end
    end
  end
end
