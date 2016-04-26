require "spec_helper"

describe Spree::PageEvent, type: :model do

  let(:guest_user_page_event) { create(:page_event, actor_id: nil) }
  let(:registered_user_page_event) { create(:page_event) }

  describe "Scopes" do
    it { expect(Spree::PageEvent.of_registered_users).to include registered_user_page_event }
    it { expect(Spree::PageEvent.of_registered_users).to_not include guest_user_page_event }
  end

end
