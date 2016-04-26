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

  factory :page_event, class: Spree::PageEvent do
    actor_id 1
    session_id "session_md5_hash"
    activity "index"
  end

end
