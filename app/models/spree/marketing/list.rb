module Spree
  module Marketing
    class List < Spree::Base

      # Constants
      TIME_FRAME = 1.week

      # Configurations
      self.table_name = "spree_marketing_lists"

      # Associations
      has_many :contacts_lists, class_name: "Spree::Marketing::ContactsList", dependent: :destroy
      has_many :contacts, through: :contacts_lists

      # Validations
      validates :uid, :name, presence: true
      validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

      # Scopes
      scope :active, -> { where(active: true) }

      def user_ids
        raise ::NotImplementedErrorList, 'You must implement user_ids method for this smart list.'
      end

      def generate list_name
        ListGenerationJob.perform_later list_name, emails, self.class.name
      end

      def update_list
        emails = emails()
        old_emails = old_emails()
        ListModificationJob.perform_later self.id, (emails - old_emails), removable_contact_uids(old_emails - emails)
      end

      def self.generator
        list = find_by(name: humanized_name)
        list ? list.update_list : new.generate(humanized_name)
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
    end
  end
end
