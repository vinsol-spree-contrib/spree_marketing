module Spree
  module Marketing
    class List < Spree::Base

      # Constants
      # LISTS = [AbandonedCartList, FavourableProductsList, LeastActiveUsersList, NewUsersList,
                # LeastZoneWiseOrdersList, MostActiveUsersList, MostDiscountedOrdersList,
                # MostSearchedKeywordsList, MostUsedPaymentMethodsList, MostZoneWiseOrdersList
              # ]
      TIME_FRAME = 1.week

      # Configurations
      self.table_name = "spree_marketing_lists"

      # Associations
      has_many :contacts_lists, class_name: "Spree::Marketing::ContactsList", dependent: :restrict_with_error
      has_many :contacts, through: :contacts_lists

      # Validations
      validates :uid, :name, presence: true
      validates :uid, uniqueness: { case_sensitive: false }, allow_blank: true

      # Scopes
      scope :active, -> { where(active: true) }

      # def fetch_list_records
      #   # @list_uid ? MailChimpApi::Call @list_uid || []
      # end

      # def new_emails
      #   emails - fetch_list_records
      # end

      def emails
        Spree.user_class.where(id: user_ids).pluck(:email)
      end

      def user_ids
        raise ::NotImplementedErrorList, 'You must implement user_ids method for this smart list.'
      end

      # def process
      #   # Spree::List.process_new_list contacts, @list_uid
      # end

      # def self.process
      #   # new.process
      # end

      def computed_time
        Time.current - time_frame
      end

      def time_frame
        @time_frame ||= self.class::TIME_FRAME
      end

    end
  end
end
