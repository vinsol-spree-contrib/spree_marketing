require "spec_helper"

describe Spree::Marketing::Recipient, type: :model do

  describe "Validations" do
    it { is_expected.to validate_presence_of(:campaign) }
    it { is_expected.to validate_presence_of(:contact) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:campaign).class_name("Spree::Marketing::Campaign") }
    it { is_expected.to belong_to(:contact).class_name("Spree::Marketing::Contact") }
  end

end
