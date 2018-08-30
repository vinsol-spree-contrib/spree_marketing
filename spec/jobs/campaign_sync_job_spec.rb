require 'spec_helper'

RSpec.describe CampaignSyncJob, type: :job do
  include ActiveJob::TestHelper

  SpreeMarketing::CONFIG ||= { Rails.env => {} }.freeze

  class GibbonServiceTest; end

  subject(:job) { described_class.perform_later(since_send_time) }

  let(:list) { create(:marketing_list) }
  let(:since_send_time) { (Time.current - 1.day).to_s }
  let(:gibbon_service) { GibbonServiceTest.new }
  let(:campaigns_data) do
    [{ id: '12456', type: 'regular', settings: { title: 'test' },
       recipients: { list_id: list.uid }, send_time: Time.current.to_s }.with_indifferent_access]
  end
  let(:contact) { create(:marketing_contact) }
  let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, status: 'sent' }.with_indifferent_access] }
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
    allow(GibbonService::CampaignService).to receive(:new).and_return(gibbon_service)
    allow(gibbon_service).to receive(:retrieve_sent_campaigns).and_return(campaigns_data)
    allow(gibbon_service).to receive(:retrieve_recipients).and_return(recipients_data)
    allow(gibbon_service).to receive(:retrieve_report).and_return(report_data)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'creates campaigns' do
    perform_enqueued_jobs { job }
    expect(Spree::Marketing::Campaign.first.uid).to eq(campaigns_data.first[:id])
  end

  it 'adds recipients to generated campaigns' do
    perform_enqueued_jobs { job }
    expect(Spree::Marketing::Campaign.first.recipients).not_to be_nil
  end

  it 'is in default queue' do
    expect(CampaignSyncJob.new.queue_name).to eq('default')
  end

  context 'executes perform' do
    after { perform_enqueued_jobs { job } }

    it 'expects GibbonService::CampaignService to be initialized' do
      expect(GibbonService::CampaignService).to receive(:new).and_return(gibbon_service)
    end
    it 'expects initialized service to retrieve sent campaigns' do
      expect(gibbon_service).to receive(:retrieve_sent_campaigns).with(since_send_time).and_return(campaigns_data)
    end
    it 'expects initialized service to retrieve recipients' do
      expect(gibbon_service).to receive(:retrieve_recipients).and_return(recipients_data)
    end
  end
end
