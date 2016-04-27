require "spec_helper"

describe Spree::Marketing::MostSearchedKeywordsList, type: :model do

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:searched_keyword) { "Test" }
  let!(:first_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }
  let!(:second_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }
  let!(:third_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }
  let!(:fourth_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }
  let!(:fifth_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }
  let!(:sixth_search_page_event) { create(:marketing_search_page_event, search_keywords: searched_keyword, actor_id: first_user.id) }

  describe "Methods" do
    context "#user_ids" do
      it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to include first_user.id }
      it { expect(Spree::Marketing::MostSearchedKeywordsList.new(searched_keyword: searched_keyword).user_ids).to_not include second_user.id }
    end

    context "#self.data" do
      it { expect(Spree::Marketing::MostSearchedKeywordsList.send :data).to include searched_keyword }
    end

    context "#self.name_text" do
      it { expect(Spree::Marketing::MostSearchedKeywordsList.send :name_text, searched_keyword).to eq "most_searched_keywords_list_Test" }
    end

    context "#self.load_list" do
      let!(:list) { create(:marketing_most_searched_keywords_list, name: "most_searched_keywords_list_Test") }
      it { expect(Spree::Marketing::MostSearchedKeywordsList.send :load_list, searched_keyword).to eq list }
    end

    context "#self.generator" do

      class GibbonServiceTest
      end

      let(:gibbon_service) { GibbonServiceTest.new }

      before do
        allow(GibbonService).to receive(:new).and_return(gibbon_service)
        allow(gibbon_service).to receive(:delete_lists).and_return(true)
      end

      context "if list already exists" do

        let(:list_name) { 'test' }
        let(:list_data) { { id: '12345678', name: list_name }.with_indifferent_access }
        let(:emails) { ['test@example.com'] }
        let(:contacts_data) { [{ id: '12345678', email_address: emails.first, unique_email_id: 'test' }.with_indifferent_access] }

        before do
          allow(gibbon_service).to receive(:update_list).and_return(contacts_data)
        end

        let!(:list) { create(:marketing_most_searched_keywords_list, name: "most_searched_keywords_list_Test") }

        it { expect { Spree::Marketing::MostSearchedKeywordsList.send :generator }.to change { Spree::Marketing::MostSearchedKeywordsList.all.count }.by 0 }
        it { expect { Spree::Marketing::MostSearchedKeywordsList.send :generator }.to change { Spree::Marketing::MostSearchedKeywordsList.last.contacts.count }.by 1 }
      end

      context "if list doesn't exists" do

        let(:list_name) { 'test' }
        let(:list_data) { { id: '12345678', name: list_name }.with_indifferent_access }
        let(:emails) { ['test@example.com'] }
        let(:contacts_data) { [{ id: '12345678', email_address: emails.first, unique_email_id: 'test' }.with_indifferent_access] }

        before do
          allow(gibbon_service).to receive(:generate_list).and_return(list_data)
          allow(gibbon_service).to receive(:subscribe_members).and_return(contacts_data)
        end

        it { expect { Spree::Marketing::MostSearchedKeywordsList.send :generator }.to change { Spree::Marketing::MostSearchedKeywordsList.all.count }.by 1 }
      end
    end
  end

end
