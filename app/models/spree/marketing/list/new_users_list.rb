module Spree
  module Marketing
    class NewUsersList < List

      private
        def emails
          Spree.user_class.where("created_at >= :time_frame", time_frame: computed_time)
                          .pluck(:email)
        end
    end
  end
end
