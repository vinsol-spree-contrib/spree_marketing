require "spec_helper"

describe Spree::Marketing::Contact, type: :model do

  let(:contact) { create(:marketing_contact) }
  let(:active_contact) { create(:marketing_contact, active: true) }
  let(:inactive_contact) { create(:marketing_contact, active: false) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:mailchimp_id) }
    it { is_expected.to validate_presence_of(:email) }
    #Spec would fail without subject assignment at db level
    context "validates uniqueness of" do
      subject { contact }
      it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end
  end

  describe "Associations" do
    it { is_expected.to have_many(:contacts_lists).class_name("Spree::Marketing::ContactsList").dependent(:restrict_with_error) }
    it { is_expected.to have_many(:lists).through(:contacts_lists) }
    it { is_expected.to have_many(:campaigns_recepients).class_name("Spree::Marketing::Recepient").dependent(:restrict_with_error) }
    it { is_expected.to have_many(:campaigns).through(:campaigns_recepients) }
  end

  describe "Scopes" do
    context ".active" do
      it { expect(Spree::Marketing::Contact.active).to include active_contact }
      it { expect(Spree::Marketing::Contact.active).to_not include inactive_contact }
    end
  end

  describe "methods" do
    context ".load" do
      let(:data) { { email_address: contact.email, id: contact.uid, unique_email_id: contact.mailchimp_id }.with_indifferent_access }
      it { expect(Spree::Marketing::Contact.load data).to eq contact }
    end
  end

end
