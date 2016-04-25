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
        ListGenerationJob.perform_later list_name, emails
      end

      def update_list
        self.contacts.destroy_all
        ListModificationJob.perform_later self, new_emails, removable_uids
      end

      def self.update
        Spree::Marketing::List.where(type: self).find_by(name: humanized_name).update_list
      end

      def self.generate
        new.generate humanized_name
      end

      def self.generate_all
        subclasses.each do |list_type|
          list_type.generate
        end
      end

      def self.update_all
        subclasses.each do |list_type|
          list_type.update
        end
      end

      private

        def removable_emails
          fetch_old_emails - emails
        end

        def self.humanized_name
          self.name.demodulize.underscore
        end

        def computed_time
          Time.current - time_frame
        end

        def time_frame
          @time_frame ||= self.class::TIME_FRAME
        end

        def emails
          Spree.user_class.where(id: user_ids).pluck(:email)
        end

        def removable_uids
          Spree::Marketing::Contact.where(email: removable_emails).pluck(:uid)
        end

        def fetch_old_emails
          gibbon_service = GibbonService.new(list_id: uid)
          gibbon_service.members.map { |member| member["email_address"] }
        end

        def new_emails
          emails - fetch_old_emails
        end
    end
  end
end
