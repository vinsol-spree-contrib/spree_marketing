require 'spec_helper'

describe Spree::Marketing::MostSearchedKeywordsList, type: :model do

  let!(:user_with_search_event_for_searched_keyword) { create(:user) }
  let!(:searched_keyword) { 'Test' }
  let(:entity_id) { searched_keyword }
  let(:entity_name) { searched_keyword }
  let(:entity_key) { 'searched_keyword' }
  let!(:search_page_events_for_search_keywords) { create_list(:marketing_search_page_event, 6, search_keywords: searched_keyword, actor_id: user_with_search_event_for_searched_keyword.id) }

  it_behaves_like 'acts_as_multilist', Spree::Marketing::MostSearchedKeywordsList

  describe 'Constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::MostSearchedKeywordsList::NAME_TEXT).to eq 'Most Searched Keywords'
    end
    it 'ENTITY_KEY equals to entity attribute for list' do
      expect(Spree::Marketing::MostSearchedKeywordsList::ENTITY_KEY).to eq 'searched_keyword'
    end
    it 'ENTITY_TYPE equals to type of entity for list' do
      expect(Spree::Marketing::MostSearchedKeywordsList::ENTITY_TYPE).to be_nil
    end
    it 'TIME_FRAME equals to time frame used in filtering of users for list' do
      expect(Spree::Marketing::MostSearchedKeywordsList::TIME_FRAME).to eq 1.month
    end
    it 'MOST_SEARCHED_KEYWORD_COUNT equals to count of keywords to be used for data for lists' do
      expect(Spree::Marketing::MostSearchedKeywordsList::MOST_SEARCHRD_KEYWORD_COUNT).to eq 5
    end
    it 'AVAILABLE_REPORTS equals to array of reports for this list type' do
      expect(Spree::Marketing::MostSearchedKeywordsList::AVAILABLE_REPORTS).to eq [:cart_additions_by, :purchases_by]
    end
  end

  describe 'Methods' do
    describe '#user_ids' do
      context 'when search events were created before TIME_FRAME' do
        let(:timestamp) { Time.current - 2.month }
        let(:user_with_old_search_event) { create(:user) }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: user_with_old_search_event.id, created_at: timestamp) }

        it 'includes users with search event for the entity keyword' do
          expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include user_with_search_event_for_searched_keyword.id
        end
        it "doesn't include users with search event for the entity keyword created before time frame" do
          expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include user_with_old_search_event.id
        end
      end

      context 'when user is not registered' do
        let!(:guest_user_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor: nil) }

        it "doesn't include guest user page events" do
          expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include nil
        end
      end

      context 'when actor of search events is not a type of Spree.user_class' do
        let(:other_user_type_id) { 9 }
        let!(:other_type_user_page_event) { create(:marketing_search_page_event, actor_id: other_user_type_id, actor_type: nil) }

        it "doesn't include other user type id" do
          expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include other_user_type_id
        end
      end

      context 'with users having search events of entity keyword and other keywords' do
        let(:another_searched_keyword) { 'Sample' }
        let(:user_with_search_event_for_another_searched_keyword) { create(:user) }
        let!(:another_search_page_event) { create(:marketing_search_page_event, search_keywords: another_searched_keyword, actor_id: user_with_search_event_for_another_searched_keyword.id) }

        it 'includes users having search events for the entity keyword' do
          expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include user_with_search_event_for_searched_keyword.id
        end
        it "doesn't includes users having only search events for keywords other than the entity keyword" do
          expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include user_with_search_event_for_another_searched_keyword.id
        end
      end
    end

    describe '.data' do
      context 'method flow' do
        it 'includes searched keyword' do
          expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include searched_keyword
        end
      end

      context 'limit to MOST_SEARCHRD_KEYWORD_COUNT' do
        let(:second_searched_keyword) { 'Sample 2' }
        let(:third_searched_keyword) { 'Sample 3' }
        let(:fourth_searched_keyword) { 'Sample 4' }
        let(:fifth_searched_keyword) { 'Sample 5' }
        let(:sixth_searched_keyword) { 'Sample 6' }
        let!(:search_page_events_for_second_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: second_searched_keyword) }
        let!(:search_page_events_for_third_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: third_searched_keyword) }
        let!(:search_page_events_for_fourth_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: fourth_searched_keyword) }
        let!(:search_page_events_for_fifth_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: fifth_searched_keyword) }
        let!(:search_page_events_for_sixth_searched_keyword) { create_list(:marketing_search_page_event, 1, search_keywords: sixth_searched_keyword) }

        it 'only includes 5 keywords which are most searched' do
          expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include *[searched_keyword, second_searched_keyword, third_searched_keyword, fourth_searched_keyword, fifth_searched_keyword]
        end
        it "doesn't keyword which is not in top 5 most searched" do
          expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to_not include sixth_searched_keyword
        end
      end

      context 'with old search events of keywords' do
        let(:other_searched_keyword) { "Ruby" }
        let(:timestamp) { Time.current - 1.month }
        let!(:search_page_events_for_second_searched_keyword) { create_list(:marketing_search_page_event, 6, search_keywords: other_searched_keyword, created_at: timestamp) }

        it 'returns keywords which will not include keyword having searh events only before time frame' do
          expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to_not include other_searched_keyword
        end
      end
    end

    context '#entity_name' do
      it 'returns the searched keyword' do
        expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).send :entity_name).to eq entity_name
      end
    end
  end

end
