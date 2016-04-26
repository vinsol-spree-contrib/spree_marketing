FactoryGirl.define do

  factory :list, class: Spree::Marketing::List do
    uid { Faker::Number.number(8) }
    name { Faker::Name.name }
  end

end
