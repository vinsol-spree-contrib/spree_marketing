module Spree
  module Marketing
    module SmartList
      class LeastActiveUsersList < BaseList
        def user_ids
          Spree::PageEvent.group(:actor_type, :actor_id)
                          .where.not(actor_id: nil)
                          .where("created_at >= :time_frame", time_frame: computed_time_frame)
                          .where(actor_type: Spree.user_class)
                          .order("COUNT(spree_orders.id)")
                          .pluck(:actor_id)
        end
      end
    end
  end
end
