desc "generate campaigns part-2 for version 1"
namespace :campaign do
  namespace :third_set do
    task generate: :environment do |t, args|

      # All Lists
      Spree::Marketing::List.includes(:contacts).each do |list|
        campaign = Spree::Marketing::Camapign.create(name: list.name + " Campaign" + list.entity_name, list: list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current, stats: "{}")
        list.contacts.each do |contact|
          campaign.contacts << contact
        end
      end

    end
  end
end
