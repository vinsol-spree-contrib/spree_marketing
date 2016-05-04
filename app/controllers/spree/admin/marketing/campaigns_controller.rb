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
            @recepients_count = @marketing_campaign.recepients.count
            @reports = JSON.parse @marketing_campaign.stats
          end

          def find_resource
            Spree::Marketing::Campaign.includes(:recepients).find(params[:id])
          end

      end
    end
  end
end
