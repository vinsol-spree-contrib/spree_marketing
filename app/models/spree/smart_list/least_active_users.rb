module Spree
  module SmartList
    class LeastActiveUsers < Base

      def initialize list_uid = nil
        @list_uid = list_uid
      end

      def formatted_contacts
        query
      end

      def query
        users = Spree::PageEvent.includes(:actor)
                                .group(:actor_type, :actor_id)
                                .where.not(actor_id: nil)
                                .where("created_at >= :time_frame", time_frame: computed_time_frame)
                                .where(actor_type: Spree.user_class)
                                .order("COUNT(spree_page_events.id)")
                                .map { |page_event| page_event.actor.email }
        super.pluck(:email) - users + users
      end

    end
  end
end
