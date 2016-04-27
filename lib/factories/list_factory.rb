FactoryGirl.define do

  factory :marketing_list, class: Spree::Marketing::List do
    uid { Faker::Number.number(8) }
    name { Faker::Name.name }
  end

  factory :marketing_most_searched_keywords_list, class: Spree::Marketing::MostSearchedKeywordsList do
    uid { Faker::Number.number(8) }
    name { Faker::Name.name }
  end

end
