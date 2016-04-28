require "spec_helper"

describe Spree::Marketing::FavourableProductsList, type: :model do

  let(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:product) { create(:product, name: "Ruby On Rails Tote") }
  let(:entity_key) { product.id }
  let(:entity_name) { product.name.downcase.gsub(" ", "_") }
  let(:variant) { create(:base_variant, product: product) }
  let(:line_item) { create(:line_item, variant: variant) }
  let!(:first_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::FavourableProductsList

  describe "Constants" do
    it { expect(Spree::Marketing::FavourableProductsList::ENTITY_KEY).to eq "product_id" }
    it { expect(Spree::Marketing::FavourableProductsList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::FavourableProductsList::FAVOURABLE_PRODUCT_COUNT).to eq 10 }
  end

  describe "methods" do
    context ".product_name" do
      it { expect(Spree::Marketing::FavourableProductsList.send :product_name, product.id).to eq "ruby_on_rails_tote" }
    end

    context ".name_text" do
      it { expect(Spree::Marketing::FavourableProductsList.send :name_text, product.id).to eq "favourable_products_list_ruby_on_rails_tote" }
    end

    context ".data" do
      context "method flow" do
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include product.id }
      end

      context "limit to constant FAVOURABLE_PRODUCT_COUNT" do
        let(:second_product) { create(:product, name: "Sample") }
        let(:second_variant) { create(:base_variant, product: second_product) }
        let(:line_item) { create(:line_item, variant: second_variant) }
        let!(:other_product_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: second_user.id) }
        before { Spree::Marketing::FavourableProductsList::FAVOURABLE_PRODUCT_COUNT = 1 }

        it { expect(Spree::Marketing::FavourableProductsList.send :data).to_not include product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include second_product.id }
      end
    end

    describe "#user_ids" do
      context "method flow" do
        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include second_user.id }
      end

      context "when user is not registered" do
        let!(:guest_user_complete_order) { create(:completed_order_with_totals, line_items: [line_item], email: "spree@example.com", user_id: nil) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).send :emails).to_not include guest_user_complete_order.email }
      end

      context "order completed at is before TIME_FRAME" do
        let(:registered_user_old_complete_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: second_user.id) }
        before { registered_user_old_complete_order.update_columns(completed_at: Time.current - 2.months) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include second_user.id }
      end

      context "only given product id is used" do
        let(:second_product) { create(:product, name: "Sample") }
        let(:second_variant) { create(:base_variant, product: second_product) }
        let(:line_item) { create(:line_item, variant: second_variant) }
        let!(:other_product_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: second_user.id) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include second_user.id }
      end
    end
  end

end
