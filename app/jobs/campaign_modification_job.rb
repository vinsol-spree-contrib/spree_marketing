class CampaignModificationJob < ActiveJob::Base
  include ::MailchimpErrorHandler

  queue_as :default

  def perform(campaign_id = nil)
    campaign = Spree::Marketing::Campaign.find_by(id: campaign_id) if campaign_id
    if campaign
      gibbon_service = GibbonService::CampaignService.new(campaign.uid)
      report_data = gibbon_service.retrieve_report
      if campaign.update_stats(report_data)
        recipients_data = gibbon_service.retrieve_recipients.select { |rec| rec['last_open'].present? }
        campaign.recipients.email_unopened.includes(:contact).update_opened_at(recipients_data)
      end
    end
  end
end
