module Spree
  class Contact < ActiveRecord::Base

    has_many :contacts_lists, class_name: "Spree::ContactsLists"
    has_many :lists, through: :contacts_lists

    validates :uid, :email, :mailchimp_id, presence: true
    validates :uid, :email, uniqueness: { case_sensitive: false }

  end
end
