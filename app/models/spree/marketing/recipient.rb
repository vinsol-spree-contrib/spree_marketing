module Spree
  module Marketing
    class Recipient < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_recipients"

      # Validations
      validates :campaign, :contact, presence: true
      validates :contact_id, uniqueness: { scope: :campaign_id }, allow_blank: true

      # Associations
      belongs_to :campaign, class_name: "Spree::Marketing::Campaign"
      belongs_to :contact, class_name: "Spree::Marketing::Contact"

      #scopes
      scope :email_unopened, -> { where(email_opened_at: nil) }
      scope :with_emails, ->(emails) { eager_load(:contact).where('spree_marketing_contacts.email IN (?)', emails) }

      #delegates
      delegate :email, :uid, :user, to: :contact, prefix: true

      def self.update_email_opened_at(recipients_data)
        uids = {}
        recipients_data.each do |data|
          uids[data['email_id']] = data['last_open']
        end
        all.each do |recipient|
          email_opened_at = uids[recipient.contact_uid]
          recipient.update(email_opened_at: email_opened_at) if email_opened_at
        end
      end

      def self.log_ins_data campaign
        Spree::Order.of_registered_users
                    .where("completed_at >= :scheduled_time", campaign.scheduled_at)
                    .where(user_id: user_ids)
                    .group(:user_id)
                    .pluck("spree_marketing_contacts.email", "spree_orders.completed_at")
                    .to_h
      end

      def self.product_views_data campaign
        Spree::PageEvent.of_registered_users
                        .where("created_at >= ?", campaign.scheduled_at)
                        .where(actor_id: user_ids, target_type: "Spree::Product")
                        .group(:actor_id)
                        .pluck("spree_marketing_contacts.email", "spree_page_events.created_at")
                        .to_h
      end

      def self.cart_additions_data campaign
        order_ids = Spree::CartEvent.where("created_at >= ?", campaign.scheduled_at)
                                    .where(activity: :add)
                                    .uniq
                                    .pluck(:actor_id)
        Spree::Order.of_registered_users
                    .where(id: order_ids)
                    .where(user_id: user_ids)
                    .group(:user_id)
                    .pluck(:email, :updated_at)
                    .to_h
      end

      def self.purchases_data campaign
        Spree::Order.of_registered_users
                    .where("completed_at >= :scheduled_time", campaign.scheduled_at)
                    .where(user_id: user_ids)
                    .group(:user_id)
                    .pluck("spree_marketing_contacts.email", "spree_orders.completed_at")
                    .to_h
      end

      def self.user_ids
        includes(:contact).pluck("spree_marketing_contacts.user_id")
      end
    end
  end
end
