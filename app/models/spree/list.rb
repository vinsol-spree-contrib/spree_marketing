module Spree
  class List < ActiveRecord::Base

    has_many :contacts_lists, class_name: "Spree::ContactsList", dependent: :destroy
    has_many :contacts, through: :contacts_lists

    validates :uid, :name, presence: true
    validates :uid, uniqueness: { case_sensitive: false }

  end
end
