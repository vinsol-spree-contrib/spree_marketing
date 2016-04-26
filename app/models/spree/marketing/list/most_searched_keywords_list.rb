module Spree
  module Marketing
    class MostSearchedKeywordList < List

      include Spree::Marketing::ActsAsMultiList

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

      private

        def self.name_text searched_keyword
          humanized_name + "_" + searched_keyword
        end

        def self.data
          Spree::PageEvent.where(activity: "search")
                          .group(:search_keywords)
                          .order("COUNT(spree_page_events.id) DESC")
                          .limit(MOST_SEARCHRD_KEYWORD_COUNT)
                          .pluck(:search_keywords)
        end

        def self.entity_key
          'searched_keyword'
        end
    end
  end
end
