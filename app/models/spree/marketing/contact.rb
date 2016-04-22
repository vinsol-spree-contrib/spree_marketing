module Spree
  module Marketing
    class Contact < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_contacts"

      # Associations
      has_many :contacts_lists, class_name: "Spree::ContactsLists", dependent: :restrict_with_error
      has_many :lists, through: :contacts_lists

      # Validations
      validates :uid, :email, :mailchimp_id, presence: true
      validates :uid, :email, uniqueness: { case_sensitive: false }, allow_blank: true

      # Scopes
      scope :active, -> { where(active: true) }

    end
  end
end
