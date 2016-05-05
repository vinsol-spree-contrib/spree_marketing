module Spree
  module Marketing
    class Campaign < Spree::Base

      STATS_PARAMS = %w(email_id email_address status)
      DEFAULT_SEND_TIME_GAP = 1.day

      # Configurations
      self.table_name = "spree_marketing_campaigns"

      # Validations
      validates :uid, :name, :stats, :list, :scheduled_at, :mailchimp_type, presence: true
      validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

      # Associations
      belongs_to :list, -> { with_deleted }, class_name: "Spree::Marketing::List"
      has_many :recipients, class_name: "Spree::Marketing::Recipient", dependent: :restrict_with_error
      has_many :contacts, through: :recipients

      def self.generate(campaigns_data)
        campaigns_data.collect do |data|
          list = Spree::Marketing::List.with_deleted.find_by(uid: data['recipients']['list_id'])
          new(uid: data['id'],
              mailchimp_type: data['type'],
              name: data['settings']['title'],
              list: list,
              scheduled_at: data['send_time'])
        end
      end

      def self.sync(since_send_time = nil)
        CampaignSyncJob.perform_later(since_send_time || DEFAULT_SEND_TIME_GAP.ago)
      end

      def populate(recipients_data)
        self.stats = { recipients: recipients_data.map! { |data| data.slice(*STATS_PARAMS) },
                       emails_sent: recipients_data.count }
        if save
          recipients_data.each do |recipient_data|
            contact = Spree::Marketing::Contact.find_by(uid: recipient_data['email_id'])
            recipient = Spree::Marketing::Recipient.create(contact: contact, campaign: self)
          end
          # ignoring case when not saved
        end
      end
    end
  end
end
