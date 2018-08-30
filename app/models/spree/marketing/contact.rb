module Spree
  module Marketing
    class Contact < Spree::Base
      # Configurations
      self.table_name = 'spree_marketing_contacts'

      # Associations
      has_many :contacts_lists, class_name: 'Spree::Marketing::ContactsList', dependent: :restrict_with_error
      has_many :lists, through: :contacts_lists
      has_many :recipients, class_name: 'Spree::Marketing::Recipient', dependent: :restrict_with_error
      has_many :campaigns, through: :recipients
      belongs_to :user, class_name: Spree.user_class.to_s

      # Validations
      validates :uid, :email, :mailchimp_id, presence: true
      validates :uid, :email, uniqueness: { case_sensitive: false }, allow_blank: true

      # Scopes
      scope :active, -> { where(active: true) }

      def self.load(data)
        find_or_create_by(email: data['email_address'],
                          uid: data['id'],
                          mailchimp_id: data['unique_email_id'],
                          user_id: data['user_id'])
      end
    end
  end
end
