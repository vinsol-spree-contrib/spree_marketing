require 'spec_helper'

RSpec.describe ListGenerationJob, type: :job do
  include ActiveJob::TestHelper

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  class GibbonServiceTest; end

  let(:gibbon_service) { GibbonServiceTest.new }
  let(:list) { create(:marketing_list) }
  let(:list_name) { 'test' }
  let(:emails) { ['test@example.com'] }
  let(:users_data) { { 'test@example.com' => 1 } }
  let(:list_class_name) { Spree::Marketing::List.subclasses.first.name }
  let(:list_data) { { id: '12345678', name: list_name }.with_indifferent_access }
  let(:contacts_data) { [{ id: '12345678', email_address: emails.first, unique_email_id: 'test' }.with_indifferent_access] }

  before do
    allow(GibbonService::ListService).to receive(:new).and_return(gibbon_service)
    allow(gibbon_service).to receive(:generate_list).and_return(list_data)
    allow(gibbon_service).to receive(:subscribe_members).and_return(contacts_data)
  end

  subject(:job) { described_class.perform_later(list_name, users_data, list_class_name) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'creates lists' do
    perform_enqueued_jobs { job }
    expect(Spree::Marketing::List.first.uid).to eq(list_data[:id])
  end

  it 'adds contacts to generated list' do
    perform_enqueued_jobs { job }
    expect(Spree::Marketing::List.first.contacts).not_to be_nil
  end

  it 'is in default queue' do
    expect(ListGenerationJob.new.queue_name).to eq('default')
  end

  context 'executes perform' do
    it 'expect GibbonService::ListService to be initialized' do
      expect(GibbonService::ListService).to receive(:new).and_return(gibbon_service)
    end
    it 'expect initialized service to receive generate_lists' do
      expect(gibbon_service).to receive(:generate_list).with(list_name).and_return(list_data)
    end
    it 'expect initialized service to receive subscribe_members' do
      expect(gibbon_service).to receive(:subscribe_members).with(emails).and_return(contacts_data)
    end

    after { perform_enqueued_jobs { job } }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
