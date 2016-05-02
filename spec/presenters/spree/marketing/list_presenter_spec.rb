require "spec_helper"

describe Spree::Marketing::ListPresenter do

  let(:list) { create(:abandoned_cart_list, name: "abandoned_cart_list") }
  let(:product_name) { "Sample Product" }
  let(:product) { create(:product, name: product_name) }
  let(:multilist) { create(:favourable_products_list, product_id: product.id, name: "favourable_products_list_#{ product_name }") }
  let(:list_presenter) { Spree::Marketing::ListPresenter.new list }
  let(:multilist_presenter) { Spree::Marketing::ListPresenter.new multilist }

  describe "Constants" do
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["AbandonedCartList"][:presenter_name]).to eq "Abandoned Cart" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["AbandonedCartList"][:tooltip_content]).to eq "View the contact list of users who have abandoned the cart" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["FavourableProductsList"][:presenter_name]).to eq "Most Selling Products" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["FavourableProductsList"][:tooltip_content]).to eq "View the contact list of users who are part of the purchase family for top 10 most selling products" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["LeastActiveUsersList"][:presenter_name]).to eq "Least Active Users" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["LeastActiveUsersList"][:tooltip_content]).to eq "View the contact list of users corresponding to least activities" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["LeastZoneWiseOrdersList"][:presenter_name]).to eq "Cold Zone" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["LeastZoneWiseOrdersList"][:tooltip_content]).to eq "View the contact list of users in 5 lowest ordering Zone" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostActiveUsersList"][:presenter_name]).to eq "Most Active Users" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostActiveUsersList"][:tooltip_content]).to eq "View the contact list of users corresponding to most activities" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostDiscountedOrdersList"][:presenter_name]).to eq "Discount Seekers" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostDiscountedOrdersList"][:tooltip_content]).to eq "View the contact list of users who are part of the purchase family mostly for discounted orders" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostSearchedKeywordsList"][:presenter_name]).to eq "Most Searched Keywords" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostSearchedKeywordsList"][:tooltip_content]).to eq "View the contact list of users corresponding to top 10 keywords" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostUsedPaymentMethodsList"][:presenter_name]).to eq "Most Used Payment Methods" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostUsedPaymentMethodsList"][:tooltip_content]).to eq "View the contact list of users corresponding to most used payment methods" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostZoneWiseOrdersList"][:presenter_name]).to eq "Hot Zone" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["MostZoneWiseOrdersList"][:tooltip_content]).to eq "View the contact list of users in 5 most ordering Zone" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["NewUsersList"][:presenter_name]).to eq "New Users" }
    it { expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH["NewUsersList"][:tooltip_content]).to eq "View the contact list of users who have signed up in last week" }
  end


  describe "methods" do
    context "#initialize" do
      it { expect((Spree::Marketing::ListPresenter.new list).instance_variable_get(:@list)).to eq list }
    end

    context "#name" do
      context "when list is of multilist type" do
        it { expect(multilist_presenter.name).to eq product_name }
      end

      context "when list is of single list type" do
        it { expect(list_presenter.name).to eq "Contacts" }
      end
    end

    context "#show_page_name" do
      context "when list is of multilist type" do
        it { expect(multilist_presenter.show_page_name).to eq " -> " + product_name }
      end

      context "when list is of single list type" do
        it { expect(list_presenter.show_page_name).to eq "" }
      end
    end
  end

end
