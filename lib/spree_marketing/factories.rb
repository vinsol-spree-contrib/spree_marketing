FactoryGirl.define do

  factory :valid_contact, class: Spree::Marketing::Contact do
    uid "Sampleuid"
    mailchimp_id "mailchimpuid"
    email "vinay@vinsol.com"
  end

  factory :valid_list, class: Spree::Marketing::List do
    uid "Sampleuid"
    name "sample list"
  end

end
