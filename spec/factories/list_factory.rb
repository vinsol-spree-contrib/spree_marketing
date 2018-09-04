FactoryBot.define do
  factory :marketing_list, class: Spree::Marketing::List do
    uid { Faker::Number.number(8) }
    name { Faker::Name.name }
  end

  Spree::Marketing::List.subclasses.each do |sub_class|
    factory_name = sub_class.to_s.demodulize.underscore.to_sym
    factory factory_name, parent: :marketing_list, class: sub_class do
    end
  end
end
