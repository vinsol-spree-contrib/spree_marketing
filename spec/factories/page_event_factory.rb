FactoryBot.define do
  factory :marketing_page_event, class: Spree::PageEvent do
    actor_type { Spree.user_class.to_s }
    actor_id { 1 }
    session_id { Faker::Number.number(16) }
    activity { 'index' }
  end

  factory :marketing_search_page_event, class: Spree::PageEvent do
    actor_type { Spree.user_class.to_s }
    actor_id { 1 }
    session_id { Faker::Number.number(16) }
    activity { 'search' }
    search_keywords { Faker::Name.name }
  end

  factory :marketing_product_view_event, class: Spree::PageEvent do
    actor_type { Spree.user_class.to_s }
    actor_id { 1 }
    session_id { Faker::Number.number(16) }
    activity { 'view' }
    target_type { 'Spree::Product' }
    target_id { 1 }
  end
end
