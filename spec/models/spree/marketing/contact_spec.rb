require "spec_helper"

describe Spree::Marketing::Contact, type: :model do

  let(:active_contact) { create(:valid_contact, active: true) }
  let(:inactive_contact) { create(:valid_contact, active: false) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:mailchimp_id) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:uid).case_insensitive.allow_nil }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive.allow_nil }
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

end
