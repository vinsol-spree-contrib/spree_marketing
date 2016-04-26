FactoryGirl.define do

  factory :page_event, class: Spree::PageEvent do
    actor_type Spree.user_class
    actor_id 1
    session_id { Faker::Number.number(16) }
    activity "index"
  end

end
