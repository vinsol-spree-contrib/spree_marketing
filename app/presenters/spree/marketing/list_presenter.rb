module Spree
  module Marketing
    class ListPresenter

      VIEW_NAMES_HASH = {
        "AbandonedCartList" => {
          presenter_name: "Abandoned Cart",
          tooltip_content: "View the contact list of users who have abandoned the cart"
        },
        "FavourableProductsList" => {
          presenter_name: "Most Selling Products",
          tooltip_content: "View the contact list of users who are part of the purchase family for top 10 most selling products"
        },
        "LeastActiveUsersList" => {
          presenter_name: "Least Active Users",
          tooltip_content: "View the contact list of users corresponding to least activities"
        },
        "LeastZoneWiseOrdersList" => {
          presenter_name: "Cold Zone",
          tooltip_content: "View the contact list of users in 5 lowest ordering Zone"
        },
        "MostActiveUsersList" => {
          presenter_name: "Most Active Users",
          tooltip_content: "View the contact list of users corresponding to most activities"
        },
        "MostDiscountedOrdersList" => {
          presenter_name: "Discount Seekers",
          tooltip_content: "View the contact list of users who are part of the purchase family mostly for discounted orders"
        },
        "MostSearchedKeywordsList" => {
          presenter_name: "Most Searched Keywords",
          tooltip_content: "View the contact list of users corresponding to top 10 keywords"
        },
        "MostUsedPaymentMethodsList" => {
          presenter_name: "Most Used Payment Methods",
          tooltip_content: "View the contact list of users corresponding to most used payment methods"
        },
        "MostZoneWiseOrdersList" => {
          presenter_name: "Hot Zone",
          tooltip_content: "View the contact list of users in 5 most ordering Zone"
        },
        "NewUsersList" => {
          presenter_name: "New Users",
          tooltip_content: "View the contact list of users who have signed up in last week"
        }
      }

      def initialize list
        @list = list
      end

      def name
        entity.try(:name) || searched_keyword || "Contacts"
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
