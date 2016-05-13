require 'spec_helper'

RSpec.describe GibbonService::CampaignService, type: :job do

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  let(:list) { create(:marketing_list) }
  let(:since_send_time) { 1.day.ago.to_s }
  let(:gibbon_service) { GibbonService::CampaignService.new }
  let(:campaigns_data) { { 'campaigns' => [{ id: '12456', type: 'regular', settings: { title: 'test' },
      recipients: { list_id: list.uid }, send_time: Time.current.to_s }.with_indifferent_access] } }
  let(:contact) { create(:marketing_contact) }
  let(:recipients_data) { { 'sent_to' => [{ email_id: contact.uid, email_address: contact.email, status: 'sent' }.with_indifferent_access] } }
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

  describe '#retrieve_sent_campaigns' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:campaigns).and_return(gibbon_service)
      allow(gibbon_service).to receive(:retrieve).and_return(campaigns_data)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns campaigns part path for gibbon' do
      expect(gibbon_service).to receive(:campaigns).and_return(gibbon_service)
    end
    it 'calls retrieve for campaigns from gibbon' do
      expect(gibbon_service).to receive(:retrieve).and_return(campaigns_data)
    end

    after { gibbon_service.retrieve_sent_campaigns }
  end

  describe '#retrieve_recipients' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:reports).and_return(gibbon_service)
      allow(gibbon_service).to receive(:sent_to).and_return(gibbon_service)
      allow(gibbon_service).to receive(:retrieve).and_return(recipients_data)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns reports part path for gibbon' do
      expect(gibbon_service).to receive(:reports).and_return(gibbon_service)
    end
    it 'assigns sent-to part path for gibbon' do
      expect(gibbon_service).to receive(:sent_to).and_return(gibbon_service)
    end
    it 'calls retrieve for recipients from gibbon' do
      expect(gibbon_service).to receive(:retrieve).and_return(recipients_data)
    end

    after { gibbon_service.retrieve_recipients }
  end

  describe '#retrieve_report' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:reports).and_return(gibbon_service)
      allow(gibbon_service).to receive(:retrieve).and_return(report_data)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns reports part path for gibbon' do
      expect(gibbon_service).to receive(:reports).and_return(gibbon_service)
    end
    it 'calls retrieve for reports from gibbon' do
      expect(gibbon_service).to receive(:retrieve).and_return(report_data)
    end

    after { gibbon_service.retrieve_report }
  end

end
