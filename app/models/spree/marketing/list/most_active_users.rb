module Spree
  module Marketing
    class List
      class MostActiveUsers < Spree::Marketing::List
        # Constants
        NAME_TEXT = 'Most Active Users'
        MINIMUM_PAGE_EVENT_COUNT = 5
        AVAILABLE_REPORTS = %i[cart_additions_by purchases_by product_views_by].freeze

        def user_ids
          Spree::PageEvent.group(:actor_id)
                          .having('COUNT(spree_page_events.id) > ?', MINIMUM_PAGE_EVENT_COUNT)
                          .where('created_at >= :time_frame', time_frame: computed_time)
                          .of_registered_users
                          .where(actor_type: Spree.user_class.to_s)
                          .pluck(:actor_id)
        end
      end
    end
  end
end
