module Spree
  module Marketing
    class List < Spree::Base

      # Constants
      LISTS = [:AbandonedCartList, :FavourableProductsList, :LeastActiveUsersList, :NewUsersList,
                :LeastZoneWiseOrdersList, :MostActiveUsersList, :MostDiscountedOrdersList,
                :MostSearchedKeywordsList, :MostUsedPaymentMethodsList, :MostZoneWiseOrdersList
              ]
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

      def fetch_old_emails
        gibbon_service = GibbonService.new(list_id: uid)
        gibbon_service.members.map { |member| member["email_address"] }
      end

      def new_emails
        emails - fetch_old_emails
      end

      def emails
        Spree.user_class.where(id: user_ids).pluck(:email)
      end

      def user_ids
        raise ::NotImplementedErrorList, 'You must implement user_ids method for this smart list.'
      end

      def generate class_name
        ListGenerationJob.perform_later class_name, emails
      end

      def update_list
        self.contacts.destroy_all
        ListModificationJob.perform_later self, new_emails
      end

      def self.update
        Spree::Marketing::List.where(type: self).find_by(name: self.name.humanize).update_list
      end

      def self.generate
        new.generate self.name.humanize
      end

      def computed_time
        Time.current - time_frame
      end

      def time_frame
        @time_frame ||= self.class::TIME_FRAME
      end

      def self.generate_all
        LISTS.each do |list_type|
          list_type.generate
        end
      end

      def self.update_all
        LISTS.each do |list_type|
          list_type.update
        end
      end

    end
  end
end
