module Spree
  module Marketing
    class List
      class NewUsers < Spree::Marketing::List
        # Constants
        NAME_TEXT = 'New Users'
        AVAILABLE_REPORTS = %i[log_ins_by cart_additions_by purchases_by product_views_by].freeze

        private
          def users
            Spree.user_class.where('created_at >= :time_frame', time_frame: computed_time)
          end
      end
    end
  end
end
