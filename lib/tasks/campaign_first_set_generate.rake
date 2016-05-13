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
        stats = {}
        stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
        stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
        stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
        campaign.update(stats: stats.to_json)

      # Most Active Users List
        most_active_users_list = Spree::Marketing::MostActiveUsersList.includes(:contacts).last
        campaign = Spree::Marketing::Campaign.create(name: most_active_users_list.name + " Campaign", list: most_active_users_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        most_active_users_list.contacts.each do |contact|
          campaign.contacts << contact
        end
        stats = {}
        stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
        stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
        stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
        campaign.update(stats: stats.to_json)

      # Abandoned Cart List
        abandoned_cart_list = Spree::Marketing::AbandonedCartList.includes(:contacts).last
        campaign = Spree::Marketing::Camapign.create(name: abandoned_cart_list.name + " Campaign", list: abandoned_cart_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        abandoned_cart_list.contacts.each do |contact|
          campaign.contacts << contact
        end
        stats = {}
        stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
        stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
        stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
        campaign.update(stats: stats.to_json)

      # Favourite Products (Product 2)
        second_favourite_product_list = Spree::Marketing::FavourableProductsList.last(2).first
        campaign = Spree::Marketing::Camapign.create(name: second_favourite_product_list.name + " Campaign" + list.entity_name, list: abandoned_cart_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        second_favourite_product_list.contacts.each do |contact|
          campaign.contacts << contact
        end
        stats = {}
        stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
        stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
        stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
        campaign.update(stats: stats.to_json)

    end
  end
end
