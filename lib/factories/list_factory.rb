FactoryGirl.define do

  factory :list, class: Spree::Marketing::List do
    uid { Faker::Number.number(8) }
    name { Faker::Name.name }
  end

  factory :most_searched_keywords_list, class: Spree::Marketing::MostSearchedKeywordsList do
    uid { Faker::Number.number(8) }
    name { Faker::Name.name }
  end
end
