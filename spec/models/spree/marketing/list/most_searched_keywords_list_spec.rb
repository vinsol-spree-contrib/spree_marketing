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
      context "with search events created before TIME_FRAME" do
        let(:timestamp) { Time.current - 2.month }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: second_user.id, created_at: timestamp) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include second_user.id }
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
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: another_searched_keyword, actor_id: second_user.id) }

        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include second_user.id }
      end
    end

    describe ".data" do
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

    context ".name_text" do
      it { expect(Spree::Marketing::MostSearchedKeywordsList.send :name_text, searched_keyword).to eq "most_searched_keywords_list_Test" }
    end
  end

end
