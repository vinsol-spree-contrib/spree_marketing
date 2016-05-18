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
      delegate :email, to: :contact, prefix: true

      def self.update_opened_at(recipients_data)
        uids = recipients_data.map { |data| data['email_id'] }
        contacts = Spree::Marketing::Contact.where(uid: uids).to_a
        recipients = all.to_a
        recipients_data.each do |data|
          contact = contacts.find { |contact| contact.uid == data['email_id'] }
          recipient = recipients.find { |recipient| recipient.contact_id == contact.id }
          recipient.update(email_opened_at: data['last_open']) if recipient
        end
      end

    end
  end
end
