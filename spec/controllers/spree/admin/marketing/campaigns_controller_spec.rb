require "spec_helper"

describe Spree::Admin::Marketing::CampaignsController, type: :controller do
  include ActiveJob::TestHelper

  stub_authorization!

  let(:json_stats_data) { '{ "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 }, "emails_sent": 3 }' }
  let(:campaign) { create(:marketing_campaign, stats: json_stats_data) }
  let(:campaigns) { double(ActiveRecord::Relation) }

  describe "POST sync" do
    def do_sync
      spree_post :sync
    end

    before do
      allow(Spree::Marketing::Campaign).to receive(:sync).and_return(true)
    end

    context "response" do
      before { do_sync }

      it "has 200 http status" do
        expect(response).to have_http_status 200
      end
      it "flash key in response body equal to success flash message" do
        expect(JSON.parse(response.body)["flash"]).to eq Spree.t("admin.marketing.campaigns.sync.success")
      end
    end

    context "expects to receive" do
      it "Spree::Marketing::Campaign to receive sync method and return true" do
        expect(Spree::Marketing::Campaign).to receive(:sync).and_return(true)
      end

      after { do_sync }
    end
  end

  describe "Callbacks" do
    describe "#collection" do
      def do_index
        spree_get :index
      end

      before do
        allow(Spree::Marketing::Campaign).to receive(:order).and_return(campaigns)
      end

      context "expects to receive" do
        it "Spree::Marketing::Campaign to receive order and return campaigns" do
          expect(Spree::Marketing::Campaign).to receive(:order).with(scheduled_at: :desc).and_return(campaigns)
        end

        after { do_index }
      end

      context "assigns" do
        before { do_index }

        it "assigns campaigns instance variable to campaigns_hash" do
          expect(assigns(:campaigns)).to eq campaigns
        end
      end
    end

    describe "#load_reports" do
      def do_show params
        spree_get :show, params
      end

      let(:params) { { id: campaign.id } }
      let(:recipients) { double(ActiveRecord::Relation) }
      let(:recipients_count) { 3 }
      let(:hash_stats_data) { { "log_ins" => { "emails" => ["vinay@vinsol.com"], "count" => 1 }, "emails_sent" => 3 } }
      let(:reports_data) { { "log_ins" => { "emails" => ["vinay@vinsol.com"], "count" => 1 } } }

      before do
        allow(Spree::Marketing::Campaign).to receive(:find).and_return(campaign)
      end

      context "expects to receive" do
        it "Spree::Marketing::Campaign to receive includes and return campaigns" do
          expect(Spree::Marketing::Campaign).to receive(:find).with(params[:id].to_s).and_return(campaign)
        end

        after { do_show params }
      end

      context "assigns" do
        before { do_show params }

        it "assigns recipients count to an instance variable recipients_count" do
          expect(assigns(:recipients_count)).to eq recipients_count
        end
        it "assigns stats data in hash format to an instance variable reports" do
          expect(assigns(:reports)).to eq reports_data
        end
      end
    end
  end

  after { clear_enqueued_jobs }
end
