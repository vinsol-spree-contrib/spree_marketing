module Spree
  module Reports
    class MostSearchedKeywords < Base
      def intitialize count = 10
        @count = count
      end

      def query
        Spree::PageEvent.where(action: "search")
                        .group(:search_keywords)
                        .order("COUNT(spree_page_events.id) DESC")
                        .limit(@count)
      end
    end
  end
end
