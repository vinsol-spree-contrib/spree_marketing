FactoryGirl.define do

  factory :contacts_list, class: Spree::Marketing::ContactsList do
    association :list, factory: :marketing_list
    association :contact, factory: :marketing_contact
  end

end
