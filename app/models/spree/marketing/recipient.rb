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

      def self.update_opened_at(recipients_data)
        uids = {}
        recipients_data.each do |data|
          uids[data['email_id']] = data['last_open']
        end
        all.each do |recipient|
          email_opened_at = uids[recipient.contact_uid]
          recipient.update(email_opened_at: email_opened_at)
        end
      end

    end
  end
end
