desc "generate campaigns part-1 for version 1"
namespace :campaign do
  namespace :first_set do
    task generate: :environment do |t, args|

      # New users list
        new_users_list = Spree::Marketing::NewUsersList.includes(:contacts).last
        campaign = Spree::Marketing::Campaign.create(name: new_users_list.name + " Campaign", list: new_users_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        new_users_list.contacts.each do |contact|
          campaign.contacts << contact
        end

      # Most Active Users List
        most_active_users_list = Spree::Marketing::MostActiveUsersList.includes(:contacts).last
        campaign = Spree::Marketing::Campaign.create(name: most_active_users_list.name + " Campaign", list: most_active_users_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        most_active_users_list.contacts.each do |contact|
          campaign.contacts << contact
        end

      # Abandoned Cart List
        abandoned_cart_list = Spree::Marketing::AbandonedCartList.includes(:contacts).last
        campaign = Spree::Marketing::Camapign.create(name: abandoned_cart_list.name + " Campaign", list: abandoned_cart_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        abandoned_cart_list.contacts.each do |contact|
          campaign.contacts << contact
        end

      # Favourite Products (Product 2)
        second_favourite_product_list = Spree::Marketing::FavourableProductsList.last(2).first
        campaign = Spree::Marketing::Camapign.create(name: second_favourite_product_list.name + " Campaign" + list.entity_name, list: abandoned_cart_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        second_favourite_product_list.contacts.each do |contact|
          campaign.contacts << contact
        end

    end
  end
end
