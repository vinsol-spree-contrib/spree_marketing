require 'spec_helper'

RSpec.describe ReportsGenerationJob, type: :job do
  include ActiveJob::TestHelper

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  class GibbonServiceTest; end

  let(:json_stats_data) { '{ "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 }, "emails_sent": 3, "emails_delivered": 3, "emails_opened": 3, "emails_bounced": 3 }' }
  let(:campaign) { build(:marketing_campaign, stats: json_stats_data) }

  subject(:job) { described_class.perform_later(campaign.id) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(CampaignSyncJob.new.queue_name).to eq('default')
  end

  context 'executes perform' do
    let(:report_data) { { id: "42694e9e57",
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
                            last_open: "2015-09-15T19:15:47+00:00"
                          } }.with_indifferent_access }
    before do
      campaign.update_stats(report_data)
      campaign.save
    end

    subject(:job) { described_class.perform_later(campaign.id) }

    it 'loads campaign' do
      expect(Spree::Marketing::Campaign).to receive(:find_by).with({ id: campaign.id }).and_return(campaign)
    end

    after { perform_enqueued_jobs { job } }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
