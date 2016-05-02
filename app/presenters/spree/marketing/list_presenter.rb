module Spree
  module Marketing
    class ListPresenter

      PRESENTER_NAME_HASH = {
        "AbandonedCartList" => "Abandoned Cart",
        "FavourableProductsList" => "Most Selling Products",
        "LeastActiveUsersList" => "Least Active Users",
        "LeastZoneWiseOrdersList" => "Cold Zone",
        "MostActiveUsersList" => "Most Active Users",
        "MostDiscountedOrdersList" => "Discount Seekers",
        "MostSearchedKeywordsList" => "Most Searched Keywords",
        "MostUsedPaymentMethodsList" => "Most Used Payment Methods",
        "MostZoneWiseOrdersList" => "Hot Zone",
        "NewUsersList" => "New Users"
      }

      TOOLTIP_CONTENT_HASH = {
        "AbandonedCartList" => "View the contact list of users who have abandoned the cart",
        "FavourableProductsList" => "View the contact list of users who are part of the purchase family for top 10 most selling products",
        "LeastActiveUsersList" => "View the contact list of users corresponding to least activities",
        "LeastZoneWiseOrdersList" => "View the contact list of users in 5 lowest ordering Zone",
        "MostActiveUsersList" => "View the contact list of users corresponding to most activities",
        "MostDiscountedOrdersList" => "View the contact list of users who are part of the purchase family mostly for discounted orders",
        "MostSearchedKeywordsList" => "View the contact list of users corresponding to top 10 keywords",
        "MostUsedPaymentMethodsList" => "View the contact list of users corresponding to most used payment methods",
        "MostZoneWiseOrdersList" => "View the contact list of users in 5 most ordering Zone",
        "NewUsersList" => "View the contact list of users who have signed up in last week"
      }

      def initialize list
        @list = list
      end

      def name
        class_name = @list.class.to_s.demodulize.underscore.humanize
        list_name = @list.name.humanize.remove(class_name).titleize
        list_name.present? ? list_name : "Contacts"
      end

      def show_page_name
        if name == "Contacts"
          ""
        else
          " -> " + name
        end
      end
    end
  end
end
