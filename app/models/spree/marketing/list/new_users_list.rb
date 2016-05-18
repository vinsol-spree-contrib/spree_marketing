module Spree
  module Marketing
    class NewUsersList < List

      # Constants
      NAME_TEXT = 'New Users'
      AVAILABLE_REPORTS = [:log_ins_by, :cart_additions_by, :purchases_by, :product_views_by]

      private
        def users
          Spree.user_class.where('created_at >= :time_frame', time_frame: computed_time)
        end
    end
  end
end
