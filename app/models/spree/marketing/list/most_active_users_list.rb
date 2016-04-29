module Spree
  module Marketing
    class MostActiveUsersList < List

      # Constants
      MINIMUM_PAGE_EVENT_COUNT = 5
      NAME_PRESENTER = "Most Active Users"
      TOOLTIP_CONTENT = "View the contact list of users corresponding to most activities"

      def user_ids
        Spree::PageEvent.group(:actor_id)
                        .having("COUNT(spree_page_events.id) > ?", MINIMUM_PAGE_EVENT_COUNT)
                        .where("created_at >= :time_frame", time_frame: computed_time)
                        .of_registered_users
                        .where(actor_type: Spree.user_class)
                        .pluck(:actor_id)
      end
    end
  end
end
