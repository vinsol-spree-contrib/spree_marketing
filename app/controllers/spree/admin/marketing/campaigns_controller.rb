module Spree
  module Admin
    module Marketing
      class CampaignsController < Spree::Admin::ResourceController

        before_action :load_reports, only: :show

        private

          def collection
            @campaigns = Spree::Marketing::Campaign.includes(:list).group_by { |campaign| campaign.list.class.to_s }
          end

          def load_reports
            stats = JSON.parse @marketing_campaign.stats
            @recepients_count = stats.delete("emails_sent")
            @reports = stats
          end
      end
    end
  end
end
