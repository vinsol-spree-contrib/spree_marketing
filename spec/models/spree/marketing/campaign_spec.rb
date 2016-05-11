require "spec_helper"

describe Spree::Marketing::Campaign, type: :model do

  ActiveJob::Base.queue_adapter = :test

  let(:campaign) { create(:marketing_campaign) }
  let(:list) { create(:marketing_list) }
  let(:campaigns_data) { [{ id: '12456', type: 'regular', settings: { title: 'test' },
      recipients: { list_id: list.uid }, send_time: Time.current.to_s }.with_indifferent_access] }

  describe 'Constants' do
    it 'STATS_PARAMS equals to params to select from mailchimp data for stats' do
      expect(Spree::Marketing::Campaign::STATS_PARAMS).to eq %w(email_id email_address status)
    end
    it 'DEFAULT_SEND_TIME_GAP equals to time gap since which sent campaigns are synced' do
      expect(Spree::Marketing::Campaign::DEFAULT_SEND_TIME_GAP).to eq 1.day
    end
  end

  it_behaves_like "calculate_reports"

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:list) }
    it { is_expected.to validate_presence_of(:stats) }
    it { is_expected.to validate_presence_of(:mailchimp_type) }
    it { is_expected.to validate_presence_of(:scheduled_at) }
    context "validates uniqueness of" do
      subject { campaign }
      it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
    end
  end

  describe "Associations" do
    it { is_expected.to belong_to(:list).class_name("Spree::Marketing::List") }
    it { is_expected.to have_many(:recipients).class_name("Spree::Marketing::Recipient").dependent(:restrict_with_error) }
    it { is_expected.to have_many(:contacts).through(:recipients) }
  end

  describe "Callbacks" do
    it { is_expected.to callback(:enqueue_reports_generation_job).after(:create) }
  end

  describe '.generate' do
    context 'when list is not destroyed' do
      it 'generated campaign uids equal fetched campaigns_data ids' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.uid).to eq campaigns_data.first[:id]
      end
      it 'generated campaign is associated to list' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.list).to eq list
      end
    end
    context 'when list is destroyed' do
      before { list.destroy }

      it 'generated campaign uids equal fetched campaigns_data ids' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.uid).to eq campaigns_data.first[:id]
      end
      it 'generated campaign is associated to list' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.list).to eq list
      end
    end
  end

  describe '.sync' do
    SpreeMarketing::CONFIG ||= { Rails.env => {} }

    before do
      allow(CampaignSyncJob).to receive(:perform_later).and_return(true)
    end

    it 'schedules CampaignSyncJob with since_send_time' do
      expect(CampaignSyncJob).to receive(:perform_later).with(Time.current.to_s)
    end

    after { Spree::Marketing::Campaign.sync(Time.current.to_s) }
  end

  describe '#populate' do
    let(:contact) { create(:marketing_contact) }
    let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, status: 'sent' }.with_indifferent_access] }
    let(:stats) { { recipients: recipients_data, emails_sent: recipients_data.count } }

    context 'when mailchimp campaign data is valid' do
      let(:synced_campaign) { Spree::Marketing::Campaign.generate(campaigns_data).first }

      before { synced_campaign.populate(recipients_data) }

      it 'synced campaign is saved' do
        expect(synced_campaign).to be_persisted
      end
      it 'synced campaign stats is equal to recipients set and emails sent count' do
        expect(synced_campaign.stats).to eq stats.to_s
      end
      it 'synced campaign recipients count equals mailchimp fetched recipients data' do
        expect(synced_campaign.recipients.count).to eq recipients_data.count
      end
      it 'synced recipients are associated to contacts' do
        expect(synced_campaign.recipients.first.contact).to eq contact
      end
    end

    context 'when mailcimp campaign is not valid' do
      let(:invalid_campaigns_data) { [{ id: '12456', type: 'regular', settings: { title: 'test' },
        recipients: { list_id: 'test' }, send_time: Time.current.to_s }.with_indifferent_access] }
      let(:synced_campaign) { Spree::Marketing::Campaign.generate(invalid_campaigns_data).first }

      before { synced_campaign.populate(recipients_data) }

      it 'synced campaign is not saved' do
        expect(synced_campaign).not_to be_persisted
      end
      it 'synced campaign recipients do not exist' do
        expect(synced_campaign.recipients.count).to eq 0
      end
    end
  end

  describe '#enqueue_reports_generation_job' do
    let(:not_saved_campaign) { build(:marketing_campaign) }

    it 'enqueues report generation job to run a day after campaign\'s scheduled_at' do
      expect { not_saved_campaign.save }.to have_enqueued_job(ReportsGenerationJob).at(not_saved_campaign.scheduled_at.tomorrow)
    end
  end
end
