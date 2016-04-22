module Spree
  module Marketing
    module Reports
      class MostSearchedKeywordsReport < BaseReport

        DEFAULT_COUNT_VALUE = 10

        def initialize count = nil
          super(count || DEFAULT_COUNT_VALUE)
        end

        def required_data
          Spree::PageEvent.where(action: "search")
                          .group(:search_keywords)
                          .order("COUNT(spree_page_events.id) DESC")
                          .limit(@count)
                          .pluck(:search_keywords)
        end
      end
    end
  end
end
