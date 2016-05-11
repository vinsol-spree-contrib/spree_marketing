desc "generate test data for v0.5"
namespace :test_data do
  task generate: :environment do |t, args|

    require 'csv'
    # Make a india country zone and add it in one or more shipping methods.

    USER_NAMES = [
      "vinay", "aishmita", "dilpreet", "akhil", "pankaj", "praveen", "nimish", "sidharth", "ankit",
      "sachin", "akshay", "chetna", "anurag", "rajat", "gurpreet", "ishaan", "pratibha", "manish", "mayank"
    ]

    def user_name
      USER_NAMES.sample
    end

    def random_number
      rand(10000)
    end

    def random_email
      "#{ user_name }+#{ random_number }@vinsol.com"
    end

    def random_activity
      ["view", "index", "search"].sample
    end

    def address
      Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
        state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
    end

    def random_variant
      @variants ||= Spree::Product.all.map(&:variants_including_master).flatten
      @variants.sample
    end

    def india_country
      Spree::Country.find_by(name: "India")
    end

    def promotion
      @promotion ||= Spree::Promotion.create(name: "Summer Special")
    end

    def random_indian_state
      indian_states.sample
    end

    def indian_states
      @states ||= india_country.states.sample(8)
    end

    def random_payment_method
      Spree::PaymentMethod.all.sample
    end

    def complete_order order
      order.payments.create(payment_method: random_payment_method)
      order.next
      order.next
      order.next
      order.next
      order.next
    end

    #New Users List

    new_users = []
    25.times do |count|
      new_users << Spree.user_class.find_or_create_by(email: random_email, password: "spree123", created_at: Time.current - 8.days)
    end
    15.times do |count|
      new_users << Spree.user_class.find_or_create_by(email: random_email, password: "spree123", created_at: Time.current - 7.days)
    end
    60.times do |count|
      new_users << Spree.user_class.find_or_create_by(email: random_email, password: "spree123", created_at: Time.current - 3.days)
    end


    # Most Active Users

      # Activity Count > 6
      array = []
      45.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        7.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 6
      array = []
      15.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        6.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 4
      array = []
      10.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        4.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 3
      array = []
      15.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        3.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 5
      array = []
      15.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        5.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 0
      25.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end


    # Least Active Users

      # Activity Count > 6
      array = []
      45.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        7.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 6
      array = []
      15.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        6.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 4
      array = []
      10.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        4.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 3
      array = []
      15.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        3.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 5
      array = []
      15.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        5.times do
          Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
        end
      end

      # Activity Count = 0
      25.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end


    # Abandoned Cart

      abandoned_cart_users = []
      # No additions
      array = []
      25.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        order = Spree::Order.create(user: user)
      end
      abandoned_cart_users << array

      # Some additions to cart
      array = []
      75.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
      end
      abandoned_cart_users << array

      # Some addition then removing same from cart
      array = []
      25.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        order = Spree::Order.create(user: user)
        variant = random_variant
        order.contents.add(variant)
        order.contents.remove(variant)
      end
      abandoned_cart_users << array
      abandoned_cart_users.flatten!

    # Most Discounted Orders

      # 10 users with 6 discounted orders
      array = []
      50.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        6.times do
          order = Spree::Order.create(user: user)
          order.contents.add(random_variant)
          order.ship_address = address
          order.bill_address = address
          order.promotions << promotion
          complete_order order
        end
      end

      # 10 users with less than 6 discounted orders
      array = []
      50.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        2.times do
          order = Spree::Order.create(user: user)
          order.contents.add(random_variant)
          order.ship_address = address
          order.bill_address = address
          order.promotions << promotion
          complete_order order
        end
      end

      # 10 users with 5 discounted and 1 non-discounted orders
      array = []
      50.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        5.times do
          order = Spree::Order.create(user: user)
          order.contents.add(random_variant)
          order.ship_address = address
          order.bill_address = address
          order.promotions << promotion
          complete_order order
        end
        2.times do
          order = Spree::Order.create(user: user)
          order.contents.add(random_variant)
          order.ship_address = address
          order.bill_address = address
          complete_order order
        end
      end



    # Most/Least Zone Wise Orders

      # 1st Zone
      first_state = indian_states[0]
      first_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: first_state, country: india_country, pincode: "110034", phone: "7503513633")
      25.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = first_state_address.clone
        order.bill_address = first_state_address.clone
        complete_order order
      end

      # 2nd Zone
      second_state = indian_states[1]
      second_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: second_state, country: india_country, pincode: "110034", phone: "7503513633")
      25.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = second_state_address.clone
        order.bill_address = second_state_address.clone
        complete_order order
      end

      # 3rd Zone
      third_state = indian_states[2]
      third_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: third_state, country: india_country, pincode: "110034", phone: "7503513633")
      50.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = third_state_address.clone
        order.bill_address = third_state_address.clone
        complete_order order
      end

      # 4th Zone
      fourth_state = indian_states[3]
      fourth_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: fourth_state, country: india_country, pincode: "110034", phone: "7503513633")
      100.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = fourth_state_address.clone
        order.bill_address = fourth_state_address.clone
        complete_order order
      end

      # 5th Zone
      fifth_state = indian_states[4]
      fifth_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: fifth_state, country: india_country, pincode: "110034", phone: "7503513633")
      150.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = fifth_state_address.clone
        order.bill_address = fifth_state_address.clone
        complete_order order
      end

      # 6th Zone
      sixth_state = indian_states[5]
      sixth_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: sixth_state, country: india_country, pincode: "110034", phone: "7503513633")
      200.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = sixth_state_address.clone
        order.bill_address = sixth_state_address.clone
        complete_order order
      end

      # 7th Zone
      seventh_state = indian_states[6]
      seventh_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: seventh_state, country: india_country, pincode: "110034", phone: "7503513633")
      250.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = seventh_state_address.clone
        order.bill_address = seventh_state_address.clone
        complete_order order
      end

      # 8th Zone
      eighth_state = indian_states[7]
      eighth_state_address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar",
        city: "Indian City", state: eighth_state, country: india_country, pincode: "110034", phone: "7503513633")
      250.times do
        user = Spree.user_class(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
        order.ship_address = eighth_state_address.clone
        order.bill_address = eighth_state_address.clone
        complete_order order
      end


    # Most Searched Keywords

      most_searched_keyword_users = []
      # Keyword 1
      keyword1 = "apache"
      50.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword1)
        end
        most_searched_keyword_users << user
      end

      # Keyword 2
      keyword2 = "ruby"
      50.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword2)
        end
        most_searched_keyword_users << user
      end

      # Keyword 3
      keyword3 = "rails"
      150.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword3)
        end
        most_searched_keyword_users << user
      end

      # Keyword 4
      keyword4 = "vinsol"
      200.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword4)
        end
        most_searched_keyword_users << user
      end

      # Keyword 5
      keyword5 = "mug"
      50.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword5)
        end
        most_searched_keyword_users << user
      end



    # Single User cases

      # 1st Case
        user1 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user1, activity: random_activity, session_id: Devise.friendly_token)
        end
        order = Spree::Order.create(user: user1)
        order.contents.add(random_variant)
        6.times do
          order = Spree::Order.create(user: user1)
          order.contents.add(random_variant)
          order.ship_address = first_state_address.clone
          order.bill_address = first_state_address.clone
          order.promotions << promotion
          complete_order order
        end
        6.times do
          Spree::PageEvent.create(actor: user1, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword1)
        end


      # 2nd Case
        user2 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        2.times do
          Spree::PageEvent.create(actor: user2, activity: random_activity, session_id: Devise.friendly_token)
        end
        2.times do
          order = Spree::Order.create(user: user2)
          order.contents.add(random_variant)
          order.ship_address = second_state_address.clone
          order.bill_address = second_state_address.clone
          complete_order order
        end
        order = Spree::Order.create(user: user1)
        order.contents.add(random_variant)
        6.times do
          Spree::PageEvent.create(actor: user1, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword2)
        end

      # 3rd Case
        user3 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user3, activity: random_activity, session_id: Devise.friendly_token)
        end
        6.times do
          address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
            state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
          order = Spree::Order.create(user: user3)
          order.contents.add(random_variant)
          order.ship_address = address
          order.bill_address = address
          order.promotions << promotion
          complete_order order
        end

      # 4th Case
        user4 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        Spree::PageEvent.create(actor: user4, activity: random_activity, session_id: Devise.friendly_token)
        order = Spree::Order.create(user: user4)
        order.contents.add random_variant

      # 5th Case
        user5 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        [keyword1, keyword2, keyword3, keyword4, keyword5].each do |keyword|
          6.times do
            Spree::PageEvent.create(actor: user5, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword)
          end
        end

      # 6th Case
        user6 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        order = Spree::Order.create(user: user6)
        order.contents.add random_variant
        6.times do
          order = Spree::Order.create(user: user6)
          order.contents.add(random_variant)
          order.ship_address = fifth_state_address.clone
          order.bill_address = fifth_state_address.clone
          complete_order order
        end


    # CSV files

      order_csv_file = CSV.open("#{Rails.root}/log/order.csv", "wb") do |csv|
        csv << ["order_number", "email", "product", "zone", "promotions", "payment_method"]
        Spree::Order.includes(:promotions, bill_address: [:state], payments: [:payment_method], line_items: {variant: :product})
                    .complete
                    .of_registered_users
                    .each do |order|
          order.line_items.each do |line_item|
            csv << [order.number, order.email, line_item.variant.product.name, order.bill_address.state.name, order.promotions.any?.to_s, order.payments.first.payment_method.name]
          end
        end
      end

      search_event_csv_file = CSV.open("#{Rails.root}/log/search.csv", "wb") do |csv|
        csv << ["id", "email", "searched_keyword"]
        Spree::PageEvent.of_registered_users.where(activity: "search").includes(:actor).each do |page_event|
          csv << [page_event.id, page_event.actor.email, page_event.search_keywords.to_s]
        end
      end

      page_event_csv_file = CSV.open("#{Rails.root}/log/activity.csv", "wb") do |csv|
        csv << ["id", "email", "activity"]
        Spree::PageEvent.of_registered_users.includes(:actor).each do |page_event|
          csv << [page_event.id, page_event.actor.email, page_event.activity]
        end
      end

      users_csv_file = CSV.open("#{Rails.root}/log/users.csv", "wb") do |csv|
        csv << ["id", "email", "created_at"]
        Spree.user_class.each do |user|
          csv << [user.id, user.email, user.created_at.to_formatted_s(:short)]
        end
      end

      abandoned_cart_csv_file = CSV.open("#{Rails.root}/log/abandoned_cart.csv", "wb") do |csv|
        csv << ["order_number", "email"]
        Spree::Order.includes(:user).of_registered_users.incomplete.where.not(item_count: 0).each do |order|
          csv << [order.number, order.user.email]
        end
      end

      keywords_csv_file = CSV.open("#{Rails.root}/log/keywords.csv", "wb") do |csv|
        csv << ["keyword"]
        [keyword1, keyword5, keyword2, keyword3, keyword4].each { |keyword| csv << keyword }
      end

      states_csv_file = CSV.open("#{Rails.root}/log/states.csv", "wb") do |csv|
        csv << ["state_name"]
        [first_state, second_state, third_state, fourth_state, fifth_state, sixth_state, seventh_state, eighth_state].each do |state|
          csv << [state.name]
        end
      end

      new_users_csv_file = CSV.open("#{Rails.root}/log/new_users.csv", "wb") do |csv|
        new_users.each { |user| csv << [user.email] }
      end

      abandoned_cart_csv_file = CSV.open("#{Rails.root}/log/abandoned_cart_users.csv", "wb") do |csv|
        abandoned_cart_users.each { |user| csv << [user.email] }
      end

      most_searched_keyword_csv_file = CSV.open("#{Rails.root}/log/most_searched_keyword_users.csv", "wb") do |csv|
        most_searched_keyword_users.each { |user| csv << [user.email] }
      end

  end
end
