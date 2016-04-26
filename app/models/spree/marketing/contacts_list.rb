module Spree
  module Marketing
    class ContactsList < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_contacts_lists"

      # Associations
      belongs_to :contact, class_name: "Spree::Marketing::Contact"
      belongs_to :list, class_name: "Spree::Marketing::List"

      # Validations
      validates :contact, :list, presence: true

    end
  end
end
