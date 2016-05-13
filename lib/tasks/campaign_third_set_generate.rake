desc "generate campaigns part-3 for version 1"
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
      stats = {}
      stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
      stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
      stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
      campaign.update(stats: stats.to_json)

    end
  end
end
