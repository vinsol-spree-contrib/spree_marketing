class ReportsGenerationJob < ActiveJob::Base
  queue_as :default

  def perform(campaign_id = nil)
    campaign = Spree::Marketing::Campaign.find_by(id: campaign_id) if campaign_id
    campaign&.generate_reports
  end
end
