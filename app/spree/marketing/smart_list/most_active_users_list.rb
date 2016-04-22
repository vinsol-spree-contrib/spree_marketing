module Spree
  module Marketing
    module SmartList
      class MostActiveUsersList < BaseList

        MINIMUM_COUNT = 5

        def user_ids
          Spree::PageEvent.group(:actor_type, :actor_id)
                          .having("COUNT(spree_page_events.id) > ?", MINIMUM_COUNT)
                          .where("created_at >= :time_frame", time_frame: computed_time_frame)
                          .where.not(actor_id: nil)
                          .where(actor_type: Spree.user_class)
                          .pluck(:actor_id)
        end
      end
    end
  end
end