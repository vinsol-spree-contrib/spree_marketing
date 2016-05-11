desc "generate test data for v0.5"
namespace :test_data do
  task generate: :environment do |t, args|

    # Make a india country zone and add it in one or more shipping methods.

    USER_NAMES = [
      "vinay", "aishmita", "dilpreet", "akhil", "pankaj", "praveen", "nimish", "sidharth", "ankit",
      "sachin", "akshay", "chetna", "anurag", "rajat", "gurpreet", "ishaan", "pratibha", "manish", "mayank"
    ]

    def user_name
      USER_NAMES.sample
    end

    def random_number
      rand(1000000)
    end

    def random_email
      "#{ user_name }+#{ random_number }@vinsol.com"
    end

    def random_activity
      ["view", "index", "search"].sample
    end

    def random_variant
      @variants ||= Spree::Product.all.map(&:variants_including_master).flatten
      @variants.sample
    end

    def india_country
      Spree::Country.find_by(name: "India")
    end

    def delhi_state
      Spree::State.find_by()
    end

    def promotion
      @promotion ||= Spree::Promotion.create(name: "Summer Special")
    end

    def random_indian_state
      india_country.states.sample
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

    25.times do |count|
      Spree.user_class.find_or_create_by(email: random_email, password: "spree123", created_at: Time.current - 8.days)
    end
    15.times do |count|
      Spree.user_class.find_or_create_by(email: random_email, password: "spree123", created_at: Time.current - 7.days)
    end
    60.times do |count|
      Spree.user_class.find_or_create_by(email: random_email, password: "spree123", created_at: Time.current - 3.days)
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

      # No additions
      array = []
      25.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        order = Spree::Order.create(user: user)
      end

      # Some additions to cart
      array = []
      75.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        order = Spree::Order.create(user: user)
        order.contents.add(random_variant)
      end

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


    # Most Discounted Orders

      # 10 users with 6 discounted orders
      array = []
      50.times do
        array << Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
      end
      array.each do |user|
        6.times do
          address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
            state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
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
          address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
            state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
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
          address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
            state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
          order = Spree::Order.create(user: user)
          order.contents.add(random_variant)
          order.ship_address = address
          order.bill_address = address
          order.promotions << promotion
          complete_order order
        end
        2.times do
          address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
            state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
          order = Spree::Order.create(user: user)
          order.contents.add(random_variant)
          order.ship_address = address.clone
          order.bill_address = address.clone
          complete_order order
        end
      end



    # Most/Least Zone Wise Orders

      # 1st Zone
      first_state = random_indian_state
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
      second_state = random_indian_state
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
      third_state = random_indian_state
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
      fourth_state = random_indian_state
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
      fifth_state = random_indian_state
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
      sixth_state = random_indian_state
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
      seventh_state = random_indian_state
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
      eighth_state = random_indian_state
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

      # Keyword 1
      keyword1 = "apache"
      50.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword1)
        end
      end

      # Keyword 2
      keyword2 = "ruby"
      50.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword2)
        end
      end

      # Keyword 3
      keyword3 = "rails"
      150.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword3)
        end
      end

      # Keyword 4
      keyword4 = "vinsol"
      200.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword4)
        end
      end

      # Keyword 5
      keyword5 = "mug"
      50.times do
        user = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user, activity: "search", session_id: Devise.friendly_token, search_keywords: keyword5)
        end
      end



    # Single User cases

      # 1st Case
        user1 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")

      # 2nd Case
        user2 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")

      # 3rd Case
        user3 = Spree.user_class.find_or_create_by(email: random_email, password: "spree123")
        6.times do
          Spree::PageEvent.create(actor: user3, activity: random_activity, session_id: Devise.friendly_token)
        end
        6.times do
          address = Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
            state: random_indian_state, country: india_country, pincode: "110034", phone: "7503513633")
          order = Spree::Order.create(user: user)
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

  end
end
