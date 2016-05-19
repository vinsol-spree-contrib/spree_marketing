require "spec_helper"

describe Spree::Marketing::Recipient, type: :model do
  let(:user) { create(:user) }
  let(:contact) { create(:marketing_contact, user: user) }
  let(:campaign) { build(:marketing_campaign) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:campaign) }
    it { is_expected.to validate_presence_of(:contact) }
    it { is_expected.to validate_uniqueness_of(:contact_id).scoped_to(:campaign_id) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:campaign).class_name("Spree::Marketing::Campaign") }
    it { is_expected.to belong_to(:contact).class_name("Spree::Marketing::Contact") }
  end

  describe 'Scopes' do
    before { allow(campaign).to receive_messages(enqueue_update: nil) }

    context '.email_unopened' do
      let(:recipient_with_email_opened_at) { create(:marketing_recipient, campaign: campaign, email_opened_at: Time.current) }
      let(:recipient_without_email_opened_at) { create(:marketing_recipient, campaign: campaign, email_opened_at: nil) }

      it { expect(Spree::Marketing::Recipient.email_unopened).to include recipient_without_email_opened_at }
      it { expect(Spree::Marketing::Recipient.email_unopened).to_not include recipient_with_email_opened_at }
    end

    context '.with_emails' do
      let(:recipient_with_contact_email) { create(:marketing_recipient, campaign: campaign, contact: contact) }
      let(:recipient_without_contact_email) { create(:marketing_recipient, campaign: campaign) }
      let(:recipients_with_email) { Spree::Marketing::Recipient.with_emails([contact.email]) }

      it { expect(recipients_with_email).to include recipient_with_contact_email }
      it { expect(recipients_with_email).to_not include recipient_without_contact_email }
    end
  end

  describe 'Delegates' do
    it { is_expected.to delegate_method(:uid).to(:contact).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:contact).with_prefix(true) }
    it { is_expected.to delegate_method(:user).to(:contact).with_prefix(true) }
  end

  describe '.update_email_opened_at' do
    let(:recipient) { create(:marketing_recipient, contact: contact, campaign: campaign) }
    let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, last_open: Time.current }.with_indifferent_access] }

    before do
      allow(campaign).to receive_messages(enqueue_update: nil)
      campaign.recipients << recipient
      campaign.recipients.includes(:contact).update_email_opened_at(recipients_data)
    end

    it 'updates unopened recipients\'s email_opened_at' do
      expect(recipient.reload.email_opened_at).to eq(recipients_data[0][:last_open])
    end
  end



end
