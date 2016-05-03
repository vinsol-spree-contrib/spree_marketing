module Spree
  module Marketing
    class Report < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_reports"

      # Validations
      validates :data, :report_index, :total_value, :campaign, presence: true
      validates :total_value, :report_index, numericality: { only_integer: true }, allow_blank: true

      # Associations
      belongs_to :campaign, class_name: "Spree::Marketing::Campaign"

    end
  end
end
