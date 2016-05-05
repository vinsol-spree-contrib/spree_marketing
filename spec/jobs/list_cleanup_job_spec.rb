require 'spec_helper'

RSpec.describe ListCleanupJob, type: :job do
  include ActiveJob::TestHelper

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  class GibbonServiceTest
  end

  let(:gibbon_service) { GibbonServiceTest.new }
  let(:list) { create(:marketing_list) }

  before do
    allow(GibbonService::ListService).to receive(:new).and_return(gibbon_service)
    allow(gibbon_service).to receive(:delete_lists).and_return(true)
  end

  subject(:job) { described_class.perform_later([list.uid]) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'destroys lists' do
    perform_enqueued_jobs { job }
    expect(Spree::Marketing::List.all).not_to include(list)
  end

  it 'is in default queue' do
    expect(ListCleanupJob.new.queue_name).to eq('default')
  end

  context 'executes perform' do
    it 'expect GibbonService::ListService to be initialized' do
      expect(GibbonService::ListService).to receive(:new).and_return(gibbon_service)
    end
    it 'expect initialized service to receive delete_lists' do
      expect(gibbon_service).to receive(:delete_lists).with([list.uid]).and_return(true)
    end

    after { perform_enqueued_jobs { job } }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
