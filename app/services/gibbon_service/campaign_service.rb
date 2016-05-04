module GibbonService
  class CampaignService < BaseService

    attr_reader :campaigns, :recipients

    def initialize(campaign_id = nil)
      @campaign_id = campaign_id
      @campaigns = []
      @recipients = []
    end

    def retrieve_sent_campaigns(since_send_time = nil)
      params = { params: { since_send_time: since_send_time || default_since_send_time } }
      p "Retrieving campaigns sent since #{ since_send_time }"
      @campaigns = gibbon.campaigns.retrieve(params)['campaigns']
      p 'Retrieved campaigns'
    end

    def retrieve_recipients(campaign_id = nil)
      p "Retrieving recipients for campaign_id #{ campaign_id }"
      @recipients = gibbon.reports(campaign_id || @campaign_id).sent_to.retrieve['sent_to']
      p 'Retrieved recipients'
    end

    private

      def default_since_send_time
        (Time.current - Spree::Marketing::Campaign::DEFAULT_SEND_TIME_GAP).to_s
      end
  end
end
