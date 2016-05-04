module Spree
  module Marketing
    class List < Spree::Base

      acts_as_paranoid

      # Constants
      TIME_FRAME = 1.week
      NAME_TEXT = 'List'

      # Configurations
      self.table_name = 'spree_marketing_lists'

      # Associations
      has_many :contacts_lists, class_name: 'Spree::Marketing::ContactsList', dependent: :destroy
      has_many :contacts, through: :contacts_lists
      has_many :campaigns, class_name: "Spree::Marketing::Campaign", dependent: :restrict_with_error
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
        ListGenerationJob.perform_later display_name, emails, self.class.name, entity_data
      end

      def update_list
        _emails = emails
        _old_emails = old_emails
        ListModificationJob.perform_later id, (_emails - _old_emails), removable_contact_uids(_old_emails - _emails)
      end

      def self.generator
        list = find_by(name: humanized_name)
        list ? list.update_list : new(name: humanized_name).generate
      end

      def self.generate_all
        subclasses.each do |list_type|
          list_type.generator
        end
      end

      def self.humanized_name
        @humanized_name ||= name.demodulize.underscore
      end
      private_class_method :humanized_name

      def populate(contacts_data)
        contacts_data.each do |contact_data|
          contact = Spree::Marketing::Contact.load(contact_data.slice('email_address', 'id', 'unique_email_id'))
          contacts << contact
        end
      end

      def presenter
        Spree::Marketing::ListPresenter.new self
      end

      def display_name
        self.class::NAME_TEXT
      end

      private

        def computed_time
          Time.current - time_frame
        end

        def time_frame
          @time_frame ||= self.class::TIME_FRAME
        end

        def emails
          Spree.user_class.where(id: user_ids).pluck(:email)
        end

        def removable_contact_uids(removable_emails)
          Spree::Marketing::Contact.where(email: removable_emails).pluck(:uid)
        end

        def old_emails
          contacts.pluck(:email)
        end

        def entity_data
          { entity_id: entity_id, entity_type: entity_type, searched_keyword: searched_keyword }
        end
    end
  end
end
