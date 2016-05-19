desc "generate test data for v1.0"
namespace :test_activity do
  task generate: :environment do |t, args|

    require 'csv'

    def random_activity
      ["view", "index", "search"].sample
    end

    def random_variant
      @variants ||= Spree::Product.all.map(&:variants_including_master).map { |variants| variants.in_stock }.flatten
      @variants.sample
    end

    def india_country
      Spree::Country.find_by(name: "India")
    end

    def random_indian_state
      indian_states.sample
    end

    def indian_states
      @states ||= india_country.states.sample(8)
    end

    def address
      Spree::Address.create(firstname: "Vinay", lastname: "Mittal", address1: "Patel Nagar", city: "Indian City",
        state: random_indian_state, country: india_country, zipcode: "110034", phone: "7503513633")
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

    new_users_emails = Spree::Marketing::NewUsersList.last.contacts.pluck(:email)
    new_users = Spree.user_class.where(email: new_users_emails)

    new_users.sample(200).each do |user|
      Spree::PageEvent.create(actor: user, activity: random_activity, session_id: Devise.friendly_token)
    end
    new_users.sample(150).each do |user|
      Spree::PageEvent.create(actor: user, activity: "view", session_id: Devise.friendly_token)
    end
    new_users.sample(150).each do |user|
      order = Spree::Order.create(user: user)
      order.contents.add random_variant
    end
    new_users.sample(100).each do |user|
      order = Spree::Order.create(user: user)
      order.contents.add random_variant
      order.ship_address = address
      order.bill_address = address
      complete_order order
      p order
    end


    abandoned_cart_user_emails = Spree::Marketing::AbandonedCartList.last.contacts.pluck(:email)
    abandoned_cart_users = Spree.user_class.where(email: abandoned_cart_user_emails)

    abandoned_cart_users.sample(120).each do |user|
      order = Spree::Order.create(user: user)
      order.contents.add random_variant
      order.ship_address = address
      order.bill_address = address
      complete_order order
      p order
    end


    most_searched_keyword_user_emails = []
    Spree::Marketing::MostSearchedKeywordsList.includes(:contacts).last(5).each do |list|
      most_searched_keyword_user_emails << list.contacts.pluck(:email)
    end
    most_searched_keyword_user_emails.flatten
    most_searched_keyword_users = Spree.user_class.where(email: most_searched_keyword_user_emails)

    most_searched_keyword_users.sample(150).each do |user|
      order = Spree::Order.create(user: user)
      order.contents.add random_variant
    end
    most_searched_keyword_users.sample(100).each do |user|
      order = Spree::Order.create(user: user)
      order.contents.add random_variant
      order.ship_address = address
      order.bill_address = address
      complete_order order
      p order
    end

  end
end
