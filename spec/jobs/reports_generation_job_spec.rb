require 'spec_helper'

RSpec.describe ReportsGenerationJob, type: :job do
  include ActiveJob::TestHelper

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  class GibbonServiceTest; end

  let(:campaign) { build(:marketing_campaign) }

  subject(:job) { described_class.perform_later(campaign.id) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(CampaignSyncJob.new.queue_name).to eq('default')
  end

  context 'executes perform' do

    before { campaign.save }

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
