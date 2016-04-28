require "spec_helper"

describe Spree::Marketing::MostSearchedKeywordsList, type: :model do

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:searched_keyword) { "Test" }
  let(:entity_name) { searched_keyword }
  let(:entity_key) { searched_keyword }
  let!(:first_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::MostSearchedKeywordsList

  describe "Constants" do
    it { expect(Spree::Marketing::MostSearchedKeywordsList::ENTITY_KEY).to eq 'searched_keyword' }
    it { expect(Spree::Marketing::MostSearchedKeywordsList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostSearchedKeywordsList::MOST_SEARCHRD_KEYWORD_COUNT).to eq 5 }
  end

  describe "Methods" do
    describe "#user_ids" do
      context "completed at is before TIME_FRAME" do
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: second_user.id, created_at: Time.current - 2.month) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include second_user.id }
      end

      context "guest user page event" do
        let!(:guest_user_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: nil, actor_type: nil) }

        xit { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).send :emails) }
      end

      context "other user type page event" do
        let(:other_user_type_id) { 9 }
        let!(:other_type_user_page_event) { create(:marketing_search_page_event, actor_id: other_user_type_id, actor_type: nil) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include other_user_type_id }
      end

      context "searched keyword is same" do
        let(:another_searched_keyword) { "Sample" }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: another_searched_keyword, actor_id: second_user.id) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include second_user.id }
      end
    end

    describe "#self.data" do
      context "method flow" do
        it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include searched_keyword }
      end

      context "limit to MOST_SEARCHRD_KEYWORD_COUNT" do
        let(:another_searched_keyword) { "Sample" }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: another_searched_keyword, actor_id: second_user.id) }

        before { Spree::Marketing::MostSearchedKeywordsList::MOST_SEARCHRD_KEYWORD_COUNT = 1 }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include another_searched_keyword }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to_not include searched_keyword }
      end
    end

    context "#self.name_text" do
      it { expect(Spree::Marketing::MostSearchedKeywordsList.send :name_text, searched_keyword).to eq "most_searched_keywords_list_Test" }
    end
  end

end
