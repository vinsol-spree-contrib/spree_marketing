require "spec_helper"

describe Spree::Admin::Marketing::CampaignsController, type: :controller do
  include ActiveJob::TestHelper

  stub_authorization!

  let(:json_stats_data) { '{ "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 }, "emails_sent": 3 }' }
  let(:campaign) { create(:marketing_campaign, stats: json_stats_data) }
  let(:campaigns) { double(ActiveRecord::Relation) }
  let(:recipients) { double(ActiveRecord::Relation) }

  describe 'GET display_recipient_emails' do
    let(:params) { { id: campaign.id, report_key: 'log_ins', page: 1 } }
    let(:users_activity_hash) { { "vinay@vinsol.com" => Time.current } }

    def send_request(params)
      spree_get :display_recipient_emails, params
    end

    before do
      allow(Spree::Marketing::Campaign).to receive(:find).and_return(campaign)
      allow(campaign).to receive(:recipients).and_return(recipients)
      allow(recipients).to receive(:with_emails).and_return(recipients)
      allow(recipients).to receive(:page).and_return(recipients)
      allow(recipients).to receive(:per).and_return(recipients)
      allow(recipients).to receive(:activity_data).and_return(users_activity_hash)
    end

    context "response" do
      before { send_request params }

      it "has 200 http status" do
        expect(response).to have_http_status 200
      end
      it "renders display_recipient_emails template" do
        expect(response).to render_template(:display_recipient_emails)
      end
    end

    context "with correct method flow" do
      it "Spree::Marketing::Campaign expects to receive includes and return campaigns" do
        expect(Spree::Marketing::Campaign).to receive(:find).with(params[:id].to_s).and_return(campaign)
      end
      it "campaign expects to receive recipients and return recipients" do
        expect(campaign).to receive(:recipients).and_return(recipients)
      end
      it "recipients expects to receive with_emails scope and return recipients" do
        expect(recipients).to receive(:with_emails).with(JSON.parse(json_stats_data)['log_ins']['emails']).and_return(recipients)
      end
      it "recipients expects to receive page and return recipients" do
        expect(recipients).to receive(:page).with(params[:page].to_s).and_return(recipients)
      end
      it "recipients expects to receive per and return recipients" do
        expect(recipients).to receive(:per).with(20).and_return(recipients)
      end
      it "recipients expects to receive activity_data and return users activity hash" do
        expect(recipients).to receive(:activity_data).with(*[params[:report_key], campaign.scheduled_at]).and_return(users_activity_hash)
      end

      after { send_request params }
    end

    context "assigns" do
      before { send_request params }

      it "assigns report name to an instance variable report name" do
        expect(assigns(:report_name)).to eq params[:report_key]
      end
      it "assigns recipient emails to an instance variable recipient_emails" do
        expect(assigns(:recipients)).to eq recipients
      end
      it "assigns users_activity_hash to a hash with emails as keys and activity time as its value" do
        expect(assigns(:users_activity_hash)).to eq users_activity_hash
      end
    end
  end

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

        it "assigns stats to an instance variable stats" do
          expect(assigns(:stats)).to eq hash_stats_data
        end
        it "assigns stats data in hash format to an instance variable reports" do
          expect(assigns(:reports)).to eq reports_data
        end
      end
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

end
