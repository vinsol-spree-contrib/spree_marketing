desc "generate campaigns part-2 for version 1"
namespace :campaign do
  namespace :second_set do
    task generate: :environment do |t, args|

      # Most Discounted Orders list
        most_discounted_orders_list = Spree::Marketing::MostDiscountedOrdersList.includes(:contacts).last
        campaign = Spree::Marketing::Campaign.create(name: most_discounted_orders_list.name + " Campaign", list: most_discounted_orders_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        most_discounted_orders_list.contacts.each do |contact|
          campaign.contacts << contact
        end

      # Most Zone Wise Orders List
        most_zone_wise_orders_list = Spree::Marketing::MostActiveUsersList.includes(:contacts).last
        campaign = Spree::Marketing::Campaign.create(name: most_zone_wise_orders_list.name + " Campaign", list: most_zone_wise_orders_list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        most_zone_wise_orders_list.contacts.each do |contact|
          campaign.contacts << contact
        end

      # Most Used Payment Methods List
        Spree::Marketing::MostUsedPaymentMethodsList.includes(:contacts).each do |list|
          list = Spree::Marketing::AbandonedCartList.includes(:contacts).last
          campaign = Spree::Marketing::Camapign.create(name: list.name + " Campaign", list: list,
            uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
          list.contacts.each do |contact|
            campaign.contacts << contact
          end
        end

      # Most Searched Keywords List
        Spree::Marketing::MostSearchedKeywordsList.includes(:contacts).each do |list|
          campaign = Spree::Marketing::Camapign.create(name: list.name + " Campaign" + list.entity_name, list: list,
            uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
          list.contacts.each do |contact|
            campaign.contacts << contact
          end
        end

    end
  end
end
