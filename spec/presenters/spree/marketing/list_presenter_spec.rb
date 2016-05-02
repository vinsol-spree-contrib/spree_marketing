require "spec_helper"

describe Spree::Marketing::ListPresenter do

  let(:list) { create(:abandoned_cart_list, name: "abandoned_cart_list") }
  let(:product_name) { "Sample Product" }
  let(:product) { create(:product, name: product_name) }
  let(:multilist) { create(:favourable_products_list, product_id: product.id, name: "favourable_products_list_#{ product_name }") }
  let(:list_presenter) { Spree::Marketing::ListPresenter.new list }
  let(:multilist_presenter) { Spree::Marketing::ListPresenter.new multilist }

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
