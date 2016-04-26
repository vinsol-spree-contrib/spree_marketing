require "spec_helper"

describe Spree::Marketing::Contact, type: :model do

  let(:contact) { create(:contact) }
  let(:active_contact) { create(:contact, active: true) }
  let(:inactive_contact) { create(:contact, active: false) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:mailchimp_id) }
    it { is_expected.to validate_presence_of(:email) }
    context "validates uniqueness of" do
      let!(:contact1) { create(:contact) }
      let(:contact2) { build(:contact, uid: contact1.uid, email: contact1.email) }
      before { contact2.save }
      it { expect(contact2.errors[:uid]).to include I18n.t "errors.messages.taken" }
      it { expect(contact2.errors[:email]).to include I18n.t "errors.messages.taken" }
    end
  end

  describe "Associations" do
    it { is_expected.to have_many(:contacts_lists).class_name("Spree::Marketing::ContactsList").dependent(:restrict_with_error) }
    it { is_expected.to have_many(:lists).through(:contacts_lists) }
  end

  describe "Scopes" do
    context ".active" do
      it { expect(Spree::Marketing::Contact.active).to include active_contact }
      it { expect(Spree::Marketing::Contact.active).to_not include inactive_contact }
    end
  end

  describe "methods" do
    context "#load" do
      let(:data) { { "email_address" => contact.email, "id" => contact.uid, "unique_email_id" => contact.mailchimp_id } }
      it { expect(Spree::Marketing::Contact.load data).to eq contact }
    end
  end

end
