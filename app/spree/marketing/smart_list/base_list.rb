module Spree
  module Marketing
    module SmartList
      class BaseList

        LISTS = [AbondonedCart, FavourableProducts, LeastActiveUsers, LeastZoneWiseOrders,
                  MostActiveUsers, MostDiscountedOrders, MostSearchedKeywords,
                  MostUsedPaymentMethods, MostZoneWiseOrders, NewUsers
                ]
        TIME_FRAME = 1.week

        def initialize time_frame, list_uid = nil
          @list_uid = list_uid
          @time_frame = time_frame || TIME_FRAME
        end

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
          raise ::NotImplementedError, 'You must implement user_ids method for this smart list.'
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

      end
    end
  end
end
