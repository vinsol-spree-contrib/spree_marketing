require "spec_helper"

describe Spree::Marketing::List, type: :model do

  let(:active_list) { create(:valid_list, active: true) }
  let(:inactive_list) { create(:valid_list, active: false) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:uid).case_insensitive.allow_nil }
  end

  describe "Associations" do
    it { is_expected.to have_many(:contacts_lists).class_name("Spree::Marketing::ContactsList").dependent(:destroy) }
    it { is_expected.to have_many(:contacts).through(:contacts_lists) }
  end

  describe "Scopes" do
    context ".active" do
      it { expect(Spree::Marketing::List.active).to include active_list }
      it { expect(Spree::Marketing::List.active).to_not include inactive_list }
    end
  end

end
