FactoryBot.define do
  factory :marketing_recipient, class: Spree::Marketing::Recipient do
    association :campaign, factory: :marketing_campaign
    association :contact, factory: :marketing_contact
  end
end
