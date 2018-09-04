module Spree
  module Marketing
    class List
      class LeastActiveUsers < Spree::Marketing::List
        # Constants
        NAME_TEXT = 'Least Active Users'
        MAXIMUM_PAGE_EVENT_COUNT = 5
        AVAILABLE_REPORTS = %i[log_ins_by purchases_by product_views_by cart_additions_by].freeze

        def user_ids
          Spree::PageEvent.group(:actor_id)
                          .having('COUNT(spree_page_events.id) < :maximum_count', maximum_count: MAXIMUM_PAGE_EVENT_COUNT)
                          .of_registered_users
                          .where('created_at >= :time_frame', time_frame: computed_time)
                          .where(actor_type: Spree.user_class.to_s)
                          .pluck(:actor_id)
        end
      end
    end
  end
end
