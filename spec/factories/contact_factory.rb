FactoryBot.define do
  factory :marketing_contact, class: Spree::Marketing::Contact do
    uid { Faker::Number.number(8) }
    mailchimp_id { Faker::Number.number(32) }
    email { generate(:random_email) }
  end
end
