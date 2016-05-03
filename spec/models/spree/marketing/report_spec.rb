require "spec_helper"

describe Spree::Marketing::Report, type: :model do

  describe "Validations" do
    it { is_expected.to validate_presence_of(:data) }
    it { is_expected.to validate_presence_of(:report_index) }
    it { is_expected.to validate_presence_of(:total_value) }
    it { is_expected.to validate_presence_of(:campaign) }
    it { is_expected.to validate_numericality_of(:total_value).only_integer.allow_nil }
    it { is_expected.to validate_numericality_of(:report_index).only_integer.allow_nil }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:campaign).class_name("Spree::Marketing::Campaign") }
  end

end
