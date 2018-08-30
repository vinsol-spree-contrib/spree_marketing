module Spree
  module Marketing
    class List < Spree::Base
      acts_as_paranoid

      # Constants
      TIME_FRAME = 1.week
      NAME_TEXT = 'List'
      AVAILABLE_REPORTS = %i[cart_additions_by log_ins_by product_views_by purchases_by].freeze

      # Configurations
      self.table_name = 'spree_marketing_lists'

      # Associations
      has_many :contacts_lists, class_name: 'Spree::Marketing::ContactsList', dependent: :destroy
      has_many :contacts, through: :contacts_lists
      has_many :campaigns, class_name: 'Spree::Marketing::Campaign', dependent: :restrict_with_error
      # entity is the associated record for which the list is defined(e.g. Spree::Product for 'Favourable Products')
      belongs_to :entity, polymorphic: true

      # Validations
      validates :uid, :name, presence: true
      validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

      # Scopes
      scope :active, -> { where(active: true) }

      def user_ids
        raise ::NotImplementedError, 'You must implement user_ids method for this smart list.'
      end

      def generate
        ListGenerationJob.perform_later display_name, users_data, self.class.name, entity_data
      end

      def update_list
        _users_data = users_data
        _old_users_data = old_users_data
        emails = _users_data.keys
        old_emails = _old_users_data.keys
        subscribable_users_data = users_data.slice(*(emails - old_emails))
        ListModificationJob.perform_later id, subscribable_users_data, removable_contact_uids(old_emails - emails)
      end

      def self.generator
        list = find_by(name: NAME_TEXT)
        list ? list.update_list : new(name: NAME_TEXT).generate
      end

      def self.generate_all
        subclasses.each(&:generator)
      end

      def populate(contacts_data, users_data)
        contacts_data.each do |contact_data|
          contact = Spree::Marketing::Contact.load(contact_data.slice('email_address', 'id', 'unique_email_id')
                                                               .merge('user_id' => users_data[contact_data['email_address']]))
          contacts << contact
        end
      end

      def presenter
        Spree::Marketing::ListPresenter.new self
      end

      def display_name
        self.class::NAME_TEXT
      end

      def entity_name
        nil
      end

      def self.computed_time
        Time.current - self::TIME_FRAME
      end
      private_class_method :computed_time

      private
        def computed_time
          self.class.send :computed_time
        end

        def users
          Spree.user_class.where(id: user_ids)
        end

        def users_data
          users.pluck(:email, :id).to_h
        end

        def removable_contact_uids(removable_emails)
          Spree::Marketing::Contact.where(email: removable_emails).pluck(:uid)
        end

        def old_users_data
          contacts.pluck(:email, :user_id).to_h
        end

        def entity_data
          { entity_id: entity_id, entity_type: entity_type, searched_keyword: searched_keyword }
        end
    end
  end
end
