module Spree
  module Marketing
    module CalculateReports

      def log_ins_by
        actor_ids = Spree::PageEvent.of_registered_users
                                    .where(actor_id: user_ids, actor_type: Spree.user_class)
                                    .where("created_at >= :scheduled_time", scheduled_time: scheduled_at)
                                    .uniq
                                    .pluck(:actor_id)

        Spree.user_class.where(id: actor_ids).pluck(:email)
      end

      def purchases_by
        Spree::Order.of_registered_users
                    .where("completed_at >= :scheduled_time", scheduled_time: scheduled_at)
                    .where(email: contacts.pluck(:email))
                    .uniq
                    .pluck(:email)
      end

      def cart_additions_by
        actor_ids = Spree::CartEvent.where("created_at >= :scheduled_time", scheduled_time: scheduled_at)
                                    .where(activity: "add")
                                    .uniq
                                    .pluck(:actor_id)

        Spree::Order.of_registered_users
                    .where(id: actor_ids, user_id: contact_ids)
                    .uniq
                    .pluck(:email)
      end

      def product_views_by
        actor_ids = Spree::PageEvent.of_registered_users
                                    .where(actor_id: user_ids, actor_type: Spree.user_class, target_type: "Spree::Product", activity: "view")
                                    .where("created_at >= :scheduled_time", scheduled_time: scheduled_at)
                                    .uniq
                                    .pluck(:actor_id)

        Spree.user_class.where(id: actor_ids).pluck(:email)
      end

      def user_ids
        Spree.user_class.where(email: contacts.pluck(:email)).ids
      end

      def generate_reports
        stats = {}
        list.class::AVAILABLE_REPORTS.each do |report|
          emails = self.send report
          count = emails.count
          stats[report.to_s.remove("_by")] = { "emails" => emails, "count" => count }
        end
        stats["emails_sent"] = contacts.count
        update(stats: stats.to_json)
      end
    end
  end
end
