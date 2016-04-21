module Spree
  class ContactsList < ActiveRecord::Base

    # Associations
    belongs_to :contact, class_name: "Spree::Contact"
    belongs_to :list, class_name: "Spree::List"

  end
end
