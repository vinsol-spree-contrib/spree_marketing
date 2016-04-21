module Spree
  module Marketing
    class ContactsList < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_contacts_lists"

      # Associations
      belongs_to :contact, class_name: "Spree::Contact"
      belongs_to :list, class_name: "Spree::List"

    end
  end
end
