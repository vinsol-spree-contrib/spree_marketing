FactoryBot.define do
  factory :cart_addition_event, class: Spree::CartEvent do
    activity { 'add' }
    session_id { Faker::Number.number(16) }
    association :actor, factory: :order
    association :target, factory: :line_item
    variant_id { 1 }
    quantity { 1 }
    total { Faker::Number.number(2) }
  end
end
