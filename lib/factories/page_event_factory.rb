FactoryGirl.define do

  factory :page_event, class: Spree::PageEvent do
    actor_type Spree.user_class
    actor_id 1
    session_id { Faker::Number.number(16) }
    activity "index"
  end

  factory :search_page_event, class: Spree::PageEvent do
    actor_type Spree.user_class
    actor_id 1
    session_id { Faker::Number.number(16) }
    activity "search"
    search_keywords { Faker::String.string(5) }
  end

end
