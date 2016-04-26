FactoryGirl.define do

  factory :contacts_list, class: Spree::Marketing::ContactsList do
    association :list, factory: :list
    association :contact, factory: :contact
  end

end
