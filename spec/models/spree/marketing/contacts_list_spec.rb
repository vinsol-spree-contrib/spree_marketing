require "spec_helper"

describe Spree::Marketing::ContactsList, type: :model do

  describe "Validations" do
    it { is_expected.to validate_presence_of(:contact) }
    it { is_expected.to validate_presence_of(:list) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:contact).class_name("Spree::Marketing::Contact") }
    it { is_expected.to belong_to(:list).class_name("Spree::Marketing::List") }
  end

end
