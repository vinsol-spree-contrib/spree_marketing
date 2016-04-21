module Spree
  module Reports
    class TopKeywords < Base
      def query
        Spree::PageEvent.where(action: "search")
                        .group(:search_keywords)
                        .order("COUNT(spree_page_events.id) DESC")
                        .limit(@count)
      end
    end
  end
end
