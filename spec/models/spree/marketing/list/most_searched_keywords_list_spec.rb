require "spec_helper"

describe Spree::Marketing::MostSearchedKeywordsList, type: :model do

  let!(:user_with_search_event_for_searched_keyword) { create(:user) }
  let!(:searched_keyword) { "Test" }
  let(:entity_name) { searched_keyword }
  let(:entity_key) { searched_keyword }
  let!(:search_page_events_for_search_keywords) { create_list(:marketing_search_page_event, 6, search_keywords: searched_keyword, actor_id: user_with_search_event_for_searched_keyword.id) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::MostSearchedKeywordsList

  describe "Constants" do
    it { expect(Spree::Marketing::MostSearchedKeywordsList::ENTITY_KEY).to eq 'searched_keyword' }
    it { expect(Spree::Marketing::MostSearchedKeywordsList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostSearchedKeywordsList::MOST_SEARCHRD_KEYWORD_COUNT).to eq 5 }
  end

  describe "Methods" do
    describe "#user_ids" do
      context "with search events created before TIME_FRAME" do
        let(:timestamp) { Time.current - 2.month }
        let(:user_with_old_search_event) { create(:user) }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: user_with_old_search_event.id, created_at: timestamp) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include user_with_search_event_for_searched_keyword.id }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include user_with_old_search_event.id }
      end

      context "when user is not registered" do
        let!(:guest_user_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: nil, actor_type: nil) }

        xit { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).send :emails) }
      end

      context "with search events created by users of type other than Spree.user_class" do
        let(:other_user_type_id) { 9 }
        let!(:other_type_user_page_event) { create(:marketing_search_page_event, actor_id: other_user_type_id, actor_type: nil) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include other_user_type_id }
      end

      context "with users having search events of selected keyword" do
        let(:another_searched_keyword) { "Sample" }
        let(:user_with_search_event_for_another_searched_keyword) { create(:user) }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: another_searched_keyword, actor_id: user_with_search_event_for_another_searched_keyword.id) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include user_with_search_event_for_searched_keyword.id }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include user_with_search_event_for_another_searched_keyword.id }
      end
    end

    describe ".data" do
      context "method flow" do
        it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include searched_keyword }
      end

      context "limit to MOST_SEARCHRD_KEYWORD_COUNT" do
        let(:second_searched_keyword) { "Sample 2" }
        let(:third_searched_keyword) { "Sample 3" }
        let(:fourth_searched_keyword) { "Sample 4" }
        let(:fifth_searched_keyword) { "Sample 5" }
        let(:sixth_searched_keyword) { "Sample 6" }
        let!(:search_page_events_for_second_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: second_searched_keyword) }
        let!(:search_page_events_for_third_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: third_searched_keyword) }
        let!(:search_page_events_for_fourth_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: fourth_searched_keyword) }
        let!(:search_page_events_for_fifth_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: fifth_searched_keyword) }
        let!(:search_page_events_for_sixth_searched_keyword) { create_list(:marketing_search_page_event, 1, search_keywords: sixth_searched_keyword) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include *[searched_keyword, second_searched_keyword, third_searched_keyword, fourth_searched_keyword, fifth_searched_keyword] }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to_not include sixth_searched_keyword }
      end
    end

    context ".name_text" do
      it { expect(Spree::Marketing::MostSearchedKeywordsList.send :name_text, searched_keyword).to eq "most_searched_keywords_list_Test" }
    end
  end

end
