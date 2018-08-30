require 'spec_helper'

RSpec.describe CampaignModificationJob, type: :job do
  include ActiveJob::TestHelper

  SpreeMarketing::CONFIG ||= { Rails.env => {} }.freeze

  class GibbonServiceTest; end

  subject(:job) { described_class.perform_later campaign.id }

  let(:json_stats_data) { '{ "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 }, "emails_sent": 3, "emails_delivered": 3, "emails_opened": 3, "emails_bounced": 3 }' }
  let(:gibbon_service) { GibbonServiceTest.new }
  let(:campaign) { create(:marketing_campaign, stats: json_stats_data) }
  let(:contact) { create(:marketing_contact) }
  let(:recipient) { create(:marketing_recipient, contact: contact, campaign: campaign) }
  let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, status: 'sent', last_open: '2015-09-15T19:15:47+00:00' }.with_indifferent_access] }
  let(:report_data) do
    { id: '42694e9e57',
      emails_sent: 200,
      bounces: {
        hard_bounces: 0,
        soft_bounces: 2,
        syntax_errors: 0
      },
      forwards: {
        forwards_count: 0,
        forwards_opens: 0
      },
      opens: {
        opens_total: 186,
        unique_opens: 100,
        open_rate: 42,
        last_open: '2015-09-15T19:15:47+00:00'
      } }.with_indifferent_access
  end

  before do
    allow(Spree::Marketing::Campaign).to receive(:find_by).and_return(campaign)
    allow(GibbonService::CampaignService).to receive(:new).and_return(gibbon_service)
    allow(gibbon_service).to receive(:retrieve_report).and_return(report_data)
    allow(gibbon_service).to receive(:retrieve_recipients).and_return(recipients_data)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'updates recipients\' email_opened_at' do
    campaign.recipients << recipient
    perform_enqueued_jobs { job }
    expect(campaign.recipients.last.email_opened_at).to eq(recipients_data[0]['last_open'])
  end

  it 'updates campaign\'s stats' do
    stat_counts = campaign.stat_counts
    perform_enqueued_jobs { job }
    expect(campaign.stat_counts).not_to eq(stat_counts)
  end

  it 'is in default queue' do
    expect(CampaignModificationJob.new.queue_name).to eq('default')
  end

  context 'executes perform' do
    after { perform_enqueued_jobs { job } }

    it 'expects Spree::Marketing::Campaign to load campaign by campaign id' do
      expect(Spree::Marketing::Campaign).to receive(:find_by).and_return(campaign)
    end
    it 'expects GibbonService::CampaignService to be initialized' do
      expect(GibbonService::CampaignService).to receive(:new).and_return(gibbon_service)
    end
    it 'expects initialized service to retrieve recipients' do
      expect(gibbon_service).to receive(:retrieve_recipients).and_return(recipients_data)
    end
    it 'expects initialized service to retrieve report' do
      expect(gibbon_service).to receive(:retrieve_report).and_return(report_data)
    end
  end
end
