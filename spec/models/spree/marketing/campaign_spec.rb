require "spec_helper"

describe Spree::Marketing::Campaign, type: :model do

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

  describe '.generate' do
    it { expect(Spree::Marketing::Campaign.generate(campaigns_data).first.uid).to eq campaigns_data.first[:id] }
  end

  describe '.sync' do
    SpreeMarketing::CONFIG ||= { Rails.env => {} }

    before do
      allow(CampaignSyncJob).to receive(:perform_later).and_return(true)
    end

    it { expect(CampaignSyncJob).to receive(:perform_later).with(Time.current.to_s) }

    after { Spree::Marketing::Campaign.sync(Time.current.to_s) }
  end

  describe '#populate' do
    let(:contact) { create(:marketing_contact) }
    let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, status: 'sent' }.with_indifferent_access] }
    let(:synced_campaign) { Spree::Marketing::Campaign.generate(campaigns_data).first }
    let(:stats) { { recipients: recipients_data, emails_sent: recipients_data.count } }

    before { synced_campaign.populate(recipients_data) }

    it { expect(synced_campaign).to be_persisted }
    it { expect(synced_campaign.stats).to eq stats.to_s }
    it { expect(synced_campaign.recipients.count).to eq recipients_data.count }
    it { expect(synced_campaign.recipients.first.contact).to eq contact }
  end
end
