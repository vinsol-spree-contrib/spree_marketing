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
      scope :unopened, -> { where(opened_at: nil) }

      def self.update_opened_at(recipients_data)
        recipients_data.each do |data|
          recipient = find_by(email: data['email_address'])
          recipient.update(opened_at: data['last_open']) if recipient
        end
      end

    end
  end
end
