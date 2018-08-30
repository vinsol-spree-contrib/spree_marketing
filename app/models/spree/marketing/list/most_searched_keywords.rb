module Spree
  module Marketing
    class List
      class MostSearchedKeywords < Spree::Marketing::List
        include Spree::Marketing::ActsAsMultiList

        # Constants
        NAME_TEXT = 'Most Searched Keywords'
        ENTITY_KEY = 'searched_keyword'
        ENTITY_TYPE = nil
        TIME_FRAME = 1.month
        MOST_SEARCHRD_KEYWORD_COUNT = 5
        AVAILABLE_REPORTS = %i[cart_additions_by purchases_by].freeze

        def user_ids
          Spree::PageEvent.where(search_keywords: searched_keyword)
                          .where('created_at >= :time_frame', time_frame: computed_time)
                          .of_registered_users
                          .where(actor_type: Spree.user_class.to_s)
                          .group(:actor_id)
                          .pluck(:actor_id)
        end

        def entity_name
          searched_keyword
        end

        def self.data
          Spree::PageEvent.where(activity: 'search')
                          .where('created_at >= :time_frame', time_frame: computed_time)
                          .group(:search_keywords)
                          .order('COUNT(spree_page_events.id) DESC')
                          .limit(MOST_SEARCHRD_KEYWORD_COUNT)
                          .pluck(:search_keywords)
        end
        private_class_method :data
      end
    end
  end
end
