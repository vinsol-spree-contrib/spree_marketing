module Spree
  module Marketing
    module Reports
      class MostSearchedKeywords < Base
        def query
          Spree::PageEvent.where(action: "search")
                          .group(:search_keywords)
                          .order("COUNT(spree_page_events.id) DESC")
                          .limit(count)
        end

        def count
          10
        end
      end
    end
  end
end
