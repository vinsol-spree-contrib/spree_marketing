module Spree
  module Marketing
    class Recepient < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_recepients"

      # Validations
      validates :campaign, :contact, presence: true

      # Associations
      belongs_to :campaign, class_name: "Spree::Marketing::Campaign"
      belongs_to :contact, class_name: "Spree::Marketing::Contact"

    end
  end
end
