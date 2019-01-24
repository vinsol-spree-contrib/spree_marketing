module GibbonService
  class CampaignService < BaseService
    def initialize(campaign_id = nil)
      @campaign_id = campaign_id
    end

    def retrieve_sent_campaigns(since_send_time = nil)
      params = { params: { since_send_time: since_send_time || Spree::Marketing::Campaign::DEFAULT_SEND_TIME_GAP.ago.to_s } }
      p "Retrieving campaigns sent since #{since_send_time}"
      campaigns = gibbon.campaigns.retrieve(params).body['campaigns']
      p 'Retrieved campaigns'
      campaigns
    end

    def retrieve_report(campaign_id = nil)
      p "Retrieving report for campaign_id #{campaign_id}"
      report = gibbon.reports(campaign_id || @campaign_id).retrieve.body
      p 'Retrieved report'
      report
    end

    def retrieve_recipients(campaign_id = nil)
      p "Retrieving recipients for campaign_id #{campaign_id}"
      @recipients = gibbon.reports(campaign_id || @campaign_id).sent_to.retrieve.body['sent_to']
      p 'Retrieved recipients'
      @recipients
    end
  end
end
