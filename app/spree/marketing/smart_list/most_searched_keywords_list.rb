module Spree
  module Marketing
    module SmartList
      class MostSearchedKeywordList < BaseList

        TIME_FRAME = 1.month
        MOST_SEARCHRD_KEYWORD_COUNT = 5

        def initialize searched_keyword, list_uid = nil
          @searched_keyword = searched_keyword
          super(TIME_FRAME, list_uid)
        end

        def user_ids
          Spree::PageEvent.where(search_keywords: @searched_keyword)
                          .where("created_at >= :time_frame", time_frame: computed_time_frame)
                          .where.not(actor_id: nil)
                          .where(actor_type: Spree.user_class)
                          .group(:actor_id)
                          .pluck(:actor_id)
        end

        # def self.process
        #   Reports::MostSearchedKeyword.new.query.each do |keyword|

        #   end
        # end

        def data
          Spree::PageEvent.where(action: "search")
                          .group(:search_keywords)
                          .order("COUNT(spree_page_events.id) DESC")
                          .limit(MOST_SEARCHRD_KEYWORD_COUNT)
                          .pluck(:search_keywords)
        end
      end
    end
  end
end
