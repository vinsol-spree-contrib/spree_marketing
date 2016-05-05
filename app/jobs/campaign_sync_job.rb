class CampaignSyncJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(since_send_time = nil)
    gibbon_service = GibbonService::CampaignService.new
    campaigns_data = gibbon_service.retrieve_sent_campaigns(since_send_time)
    if campaigns_data.any?
      campaigns = Spree::Marketing::Campaign.generate(campaigns_data)
      campaigns.each do |campaign|
        recipients_data = gibbon_service.retrieve_recipients(campaign.uid)
        campaign.populate(recipients_data)
      end
    end
  end
end
