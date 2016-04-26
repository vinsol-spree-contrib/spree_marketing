module Spree
  module Marketing
    class LeastActiveUsersList < List

      # Constants
      MINIMUM_PAGE_EVENT_COUNT = 5

      def user_ids
        result_ids = Spree::PageEvent.group(:actor_id)
                                     .having("COUNT(spree_page_events.id) > :minimum_count", minimum_count: MINIMUM_PAGE_EVENT_COUNT)
                                     .of_registered_users
                                     .where("created_at >= :time_frame", time_frame: computed_time)
                                     .where(actor_type: Spree.user_class)
                                     .pluck(:actor_id)
        Spree.user_class.ids - result_ids
      end
    end
  end
end
