module Spree
  module Marketing
    class Campaign < Spree::Base

      # Constants
      STATS_PARAMS = %w(email_id email_address status)
      DEFAULT_SEND_TIME_GAP = 1.day

      include Spree::Marketing::CalculateReports

      # Configurations
      self.table_name = "spree_marketing_campaigns"

      # Validations
      validates :uid, :name, :stats, :list, :scheduled_at, :mailchimp_type, presence: true
      validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

      # Associations
      belongs_to :list, -> { with_deleted }, class_name: "Spree::Marketing::List"
      has_many :recipients, class_name: "Spree::Marketing::Recipient", dependent: :restrict_with_error
      has_many :contacts, through: :recipients

      # Callbacks
      # after_create :enqueue_reports_generation_job

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
        CampaignSyncJob.perform_later(since_send_time || DEFAULT_SEND_TIME_GAP.ago.to_s)
      end

      def populate(recipients_data)
        if save
          recipients_data.each do |recipient_data|
            contact = Spree::Marketing::Contact.find_by(uid: recipient_data['email_id'])
            recipient = Spree::Marketing::Recipient.create(contact: contact, campaign: self)
          end
          # ignoring case when not saved
        end
      end

      def update_stats(report_data)
        emails_bounced_count = report_data['bounces'].values.reduce(&:+)
        self.stats = { emails_sent: report_data['emails_sent'],
                       emails_bounced: emails_bounced_count,
                       emails_opened: report_data['opens']['unique_opens'],
                       emails_delivered: report_data['emails_sent'] - emails_bounced_count  }.to_json
        save
      end

      private

        def enqueue_reports_generation_job
          ReportsGenerationJob.set(wait_until: scheduled_at.tomorrow).perform_later id
        end
    end
  end
end
