desc "generate campaigns part-3 for version 1"
namespace :campaign do
  namespace :third_set do
    task generate: :environment do |t, args|

      # All Lists
      Spree::Marketing::List.includes(:contacts).each do |list|
        p list.name
        campaign = Spree::Marketing::Campaign.create(name: list.name + " Campaign", list: list,
          uid: Devise.friendly_token, mailchimp_type: "html", scheduled_at: Time.current.beginning_of_day, stats: "{}")
        p campaign
        list.contacts.each do |contact|
          campaign.contacts << contact
        end
        stats = {}
        stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
        stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
        stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
        campaign.update(stats: stats.to_json)
      end

      Spree::Marketing::Campaign.all.each do |campaign|
        stats = {}
        stats["emails_bounced"] = (campaign.contacts.size * 0.05).to_i
        stats["emails_delivered"] = campaign.contacts.size - stats["emails_bounced"]
        stats["emails_opened"] = (campaign.contacts.size * 0.25).to_i
        campaign.update(stats: stats.to_json)
        campaign.generate_reports
      end


      Spree::Marketing::Campaign.all.each do |campaign|
        stats = JSON.parse campaign.stats
        if stats["cart_additions"].present?
          emails = stats["cart_additions"]["emails"]
        else
          emails = []
        end
        emails.each do |email|
          unless campaign.contacts.find_by(email: email)
            campaign.contacts << Spree::Marketing::Contact.find_by(email: email)
          end
        end
        campaign.recipients.update_all(email_opened_at: campaign.scheduled_at + 2.hour)
      end

    end
  end
end
