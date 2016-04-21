module Spree
  module SmartList
    class MostActiveUsers < Base

      def initialize time_frame, list_uid
        @time_frame = time_frame
        @list_uid = list_uid
      end

      def query
        Spree::PageEvent.includes(:actor)
                        .group(:actor_type)
                        .group(:actor_id)
                        .having("COUNT(spree_page_events.id) > ?", 5)
                        .where("created_at >= :time_frame", time_frame: Time.current - time_frame)
                        .where.not(actor_id: nil)
                        .where(actor_type: Spree.user_class)
                        .order("COUNT(spree_page_events.id) DESC")
                        .map { |x| x.actor.email }
      end

    end
  end
end
