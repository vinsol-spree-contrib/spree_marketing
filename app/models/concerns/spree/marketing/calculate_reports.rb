module Spree
  module Marketing
    module CalculateReports

      def log_ins
        Spree::PageEvent.includes(:actor)
                        .of_registered_users
                        .where(actor_id: contact_ids)
                        .where(actor_type: Spree.user_class)
                        .where("created_at >= :scheduled_time", scheduled_time: scheduled_at)
                        .map { |page_event| page_event.actor.try :email }
                        .uniq
      end

      def purchases
        Spree::Order.of_registered_users
                    .where("completed_at >= :scheduled_time", scheduled_time: scheduled_at)
                    .where(email: contacts.pluck(:email))
                    .pluck(:email)
                    .uniq
      end

      def cart_additions
        Spree::CartEvent.includes(:actor)
                        .where("created_at >= :scheduled_time", scheduled_time: scheduled_at)
                        .where(activity: "add")
                        .map { |cart_event| cart_event.actor.try :email }
                        .uniq
                        .select { |email| contacts.pluck(:email).include?(email) }
      end

      def product_views
        Spree::PageEvent.includes(:actor)
                        .of_registered_users
                        .where(actor_id: contact_ids)
                        .where("created_at >= :scheduled_time", scheduled_time: scheduled_at)
                        .where(actor_type: Spree.user_class)
                        .where(target_type: "Spree::Product")
                        .where(activity: "view")
                        .map { |page_event| page_event.actor.try :email }
                        .uniq
      end

      def contact_ids
        Spree.user_class.where(email: contacts.pluck(:email)).ids
      end

      def make_reports
        stats = {}
        list.class::AVAILABLE_REPORTS.each do |report|
          emails = self.send report
          count = emails.count
          stats[report.to_s] = { "emails" => emails, "count" => count }
        end
        stats["emails_sent"] = recepients.count
        update(stats: stats.to_json)
      end
    end
  end
end
