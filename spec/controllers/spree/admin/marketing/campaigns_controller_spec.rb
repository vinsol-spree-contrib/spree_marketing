require "spec_helper"

describe Spree::Admin::Marketing::CampaignsController, type: :controller do

  stub_authorization!

  let(:json_stats_data) { '{ "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 } }' }
  let(:campaign) { create(:marketing_campaign, stats: json_stats_data) }
  let(:campaigns) { double(ActiveRecord::Relation) }
  let(:params) { { id: campaign.id } }

  describe "Callbacks" do
    def do_show params
      spree_get :show, params
    end

    def do_index
      spree_get :index
    end

    describe "#collection" do
      let(:abandoned_cart_list) { create(:abandoned_cart_list) }
      let(:abandoned_cart_list_campaign) { create(:marketing_campaign, list: abandoned_cart_list, stats: json_stats_data) }
      let(:campaigns_hash) { { "AbandonedCartList" => [abandoned_cart_list_campaign] } }

      before do
        allow(Spree::Marketing::Campaign).to receive(:includes).and_return(campaigns)
        allow(campaigns).to receive(:group_by).and_return(campaigns_hash)
      end

      context "expects to receive" do
        it "Spree::Marketing::Campaign to receive includes and return campaigns" do
          expect(Spree::Marketing::Campaign).to receive(:includes).with(:list).and_return(campaigns)
        end
        it "campaigns to receive group_by and return campaigns_hash" do
          expect(campaigns).to receive(:group_by).and_return(campaigns_hash)
        end

        after { do_index }
      end

      context "assigns" do
        before { do_index }

        it "assigns campaigns instance variable to campaigns_hash" do
          expect(assigns(:campaigns)).to eq campaigns_hash
        end
      end
    end

    describe "#load_reports" do
      let(:recepients) { double(ActiveRecord::Relation) }
      let(:recepients_count) { 5 }
      let(:hash_stats_data) { { "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 } } }

      before do
        allow(Spree::Marketing::Campaign).to receive(:includes).and_return(campaigns)
        allow(campaigns).to receive(:find).and_return(campaign)
        allow(campaign).to receive(:recepients).and_return(recepients)
        allow(recepients).to receive(:count).and_return(recepients_count)
        allow(JSON).to receive(:parse).and_return(hash_stats_data)
      end

      context "expects to receive" do
        it "Spree::Marketing::Campaign to receive includes and return campaigns" do
          expect(Spree::Marketing::Campaign).to receive(:includes).with(:recepients).and_return(campaigns)
        end
        it "campaigns to receive find and return campaign" do
          expect(campaigns).to receive(:find).with(params[:id].to_s).and_return(campaign)
        end
        it "campaign to receive recepients and return recepients" do
          expect(campaign).to receive(:recepients).and_return(recepients)
        end
        it "recepients to receive count and return recepients_count" do
          expect(recepients).to receive(:count).and_return(recepients_count)
        end
        it "JSON to receive parse with json_stats_data and return hash_stats_data" do
          expect(JSON).to receive(:parse).with(json_stats_data).and_return(hash_stats_data)
        end

        after { do_show params }
      end

      context "assigns" do
        before { do_show params }

        it "assigns recepients count to an instance variable recepients_count" do
          expect(assigns(:recepients_count)).to eq recepients_count
        end
        it "assigns stats data in hash format to an instance variable reports" do
          expect(assigns(:reports)).to eq hash_stats_data
        end
      end
    end

    describe "#find_resource" do
      before do
        allow(Spree::Marketing::Campaign).to receive(:includes).and_return(campaigns)
        allow(campaigns).to receive(:find).and_return(campaign)
      end

      context "expects to receive" do
        it "Spree::Marketing::Campaign to receive includes and return campaigns" do
          expect(Spree::Marketing::Campaign).to receive(:includes).with(:recepients).and_return(campaigns)
        end
        it "campaigns to receive find and return campaign" do
          expect(campaigns).to receive(:find).with(params[:id].to_s).and_return(campaign)
        end

        after { do_show params }
      end

      context "returns" do
        before { do_show params }

        it "find_resource returns campaign object" do
          expect(controller.send :find_resource).to eq campaign
        end
      end
    end

  end

end
