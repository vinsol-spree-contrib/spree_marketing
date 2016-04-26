require "spec_helper"

describe Spree::Marketing::List, type: :model do

  let(:active_list) { create(:valid_list, active: true) }
  let(:inactive_list) { create(:valid_list, active: false) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    context "validates uniqueness of" do
      let!(:list1) { create(:valid_list) }
      let(:list2) { build(:valid_list, uid: list1.uid) }
      before { list2.save }
      it { expect(list2.errors[:uid]).to include I18n.t "errors.messages.taken" }
    end
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
