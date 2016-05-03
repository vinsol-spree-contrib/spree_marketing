module Spree
  module Marketing
    class Campaign < Spree::Base

      # Configurations
      self.table_name = "spree_marketing_campaigns"

      # Validations
      validates :uid, :name, :list, :scheduled_at, :mailchimp_type, presence: true
      validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

      # Associations
      belongs_to :list, class_name: "Spree::Marketing::List"
      has_many :recepients, class_name: "Spree::Marketing::Recepient", dependent: :restrict_with_error
      has_many :contacts, through: :recepients

    end
  end
end
