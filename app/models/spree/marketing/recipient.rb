module Spree
  module Marketing
    class Recipient < Spree::Base
      # Configurations
      self.table_name = 'spree_marketing_recipients'

      # Validations
      validates :campaign, :contact, presence: true
      validates :contact_id, uniqueness: { scope: :campaign_id }, allow_blank: true

      # Associations
      belongs_to :campaign, class_name: 'Spree::Marketing::Campaign'
      belongs_to :contact, class_name: 'Spree::Marketing::Contact'

      # scopes
      scope :email_unopened, -> { where(email_opened_at: nil) }
      scope :with_emails, ->(emails) { eager_load(:contact).where('spree_marketing_contacts.email IN (?)', emails) }

      # delegates
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

      def self.log_ins_data(campaign_scheduled_at)
        timestamp_to_ids_hash = Spree::PageEvent.of_registered_users
                                                .where('created_at >= :scheduled_time', scheduled_time: campaign_scheduled_at)
                                                .where(actor_id: user_ids)
                                                .group(:actor_id)
                                                .having('created_at = MIN(created_at)')
                                                .pluck(:actor_id, :created_at)
                                                .to_h
        id_to_emails_hash = Spree.user_class.where(id: timestamp_to_ids_hash.keys).pluck(:email, :id).to_h
        timestamp_to_emails_hash = id_to_emails_hash.each { |key, value| id_to_emails_hash[key] = timestamp_to_ids_hash[value] }
      end

      def self.product_views_data(campaign_scheduled_at)
        timestamp_to_ids_hash = Spree::PageEvent.of_registered_users
                                                .where('created_at >= :scheduled_time', scheduled_time: campaign_scheduled_at)
                                                .where(actor_id: user_ids, target_type: 'Spree::Product', activity: :view)
                                                .group(:actor_id)
                                                .having('created_at = MIN(created_at)')
                                                .pluck(:actor_id, :created_at)
                                                .to_h
        id_to_emails_hash = Spree.user_class.where(id: timestamp_to_ids_hash.keys).pluck(:email, :id).to_h
        timestamp_to_emails_hash = id_to_emails_hash.each { |key, value| id_to_emails_hash[key] = timestamp_to_ids_hash[value] }
      end

      def self.cart_additions_data(campaign_scheduled_at)
        timestamp_to_ids_hash = Spree::CartEvent.where('created_at >= :scheduled_time', scheduled_time: campaign_scheduled_at)
                                                .where(activity: :add)
                                                .group(:actor_id)
                                                .having('created_at = MIN(created_at)')
                                                .pluck(:actor_id, :created_at)
                                                .to_h
        id_to_emails_hash = Spree::Order.of_registered_users
                                        .where(id: timestamp_to_ids_hash.keys)
                                        .where(user_id: user_ids)
                                        .group(:user_id)
                                        .pluck(:email, :id)
                                        .to_h
        timestamp_to_emails_hash = id_to_emails_hash.each { |key, value| id_to_emails_hash[key] = timestamp_to_ids_hash[value] }
      end

      def self.purchases_data(campaign_scheduled_at)
        Spree::Order.of_registered_users
                    .where('completed_at >= :scheduled_time', scheduled_time: campaign_scheduled_at)
                    .where(user_id: user_ids)
                    .group(:user_id)
                    .having('completed_at = MIN(completed_at)')
                    .pluck(:email, :completed_at)
                    .to_h
      end

      def self.user_ids
        includes(:contact).pluck('spree_marketing_contacts.user_id')
      end

      def self.activity_data(report_key, campaign_scheduled_at)
        send("#{report_key}_data", campaign_scheduled_at)
      end
    end
  end
end
