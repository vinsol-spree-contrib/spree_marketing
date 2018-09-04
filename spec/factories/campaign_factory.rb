FactoryBot.define do
  factory :marketing_campaign, class: Spree::Marketing::Campaign do
    uid { Faker::Number.number(8) }
    mailchimp_type { Faker::Name.name }
    name { Faker::Name.name }
    scheduled_at { Time.current }
    stats { Faker::Lorem.sentence }
    association :list, factory: :marketing_list
  end
end
