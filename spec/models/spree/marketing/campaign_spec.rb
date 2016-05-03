require "spec_helper"

describe Spree::Marketing::Campaign, type: :model do

  let(:campaign) { create(:marketing_campaign) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:list) }
    it { is_expected.to validate_presence_of(:mailchimp_type) }
    it { is_expected.to validate_presence_of(:scheduled_at) }
    context "validates uniqueness of" do
      subject { campaign }
      it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
    end
  end

  describe "Associations" do
    it { is_expected.to belong_to(:list).class_name("Spree::Marketing::List") }
    it { is_expected.to have_many(:campaigns_recepients).class_name("Spree::Marketing::Recepient").dependent(:restrict_with_error) }
    it { is_expected.to have_many(:recepients).through(:campaigns_recepients).source(:contact) }
  end

end
