FactoryGirl.define do

  factory :valid_contact, class: Spree::Marketing::Contact do
    uid { (1..8).collect { rand(10) }.join }
    mailchimp_id { (1..16).collect { rand(10) }.join }
    email "#{ Faker::Name.name }@test.com"
  end

  factory :valid_list, class: Spree::Marketing::List do
    uid { (1..8).collect { rand(10) }.join }
    name { Faker::Name.name }
  end

  factory :contacts_list, class: Spree::Marketing::ContactsList do
    association :list, factory: :valid_list
    association :contact, factory: :valid_contact
  end

  factory :page_event, class: Spree::PageEvent do
    actor_type Spree.user_class
    actor_id 1
    session_id "session_md5_hash"
    activity "index"
  end

end
