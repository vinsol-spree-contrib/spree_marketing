FactoryBot.define do
  factory :marketing_contacts, class: Spree::Marketing::ContactsList do
    association :list, factory: :marketing_list
    association :contact, factory: :marketing_contact
  end
end
