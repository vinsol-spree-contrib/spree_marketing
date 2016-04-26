FactoryGirl.define do

  factory :page_event, class: Spree::PageEvent do
    actor_id 1
    session_id "session_md5_hash"
    activity "index"
  end

end
