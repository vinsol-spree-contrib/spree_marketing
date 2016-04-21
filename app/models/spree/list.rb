module Spree
  class List < ActiveRecord::Base

    # Associations
    has_many :contacts_lists, class_name: "Spree::ContactsList", dependent: :restrict_with_error
    has_many :contacts, through: :contacts_lists

    # Validations
    validates :uid, :name, presence: true
    validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

  end
end
