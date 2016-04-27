require "spec_helper"

describe Spree::Marketing::FavourableProductsList, type: :model do

  let(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:product) { create(:product, name: "Ruby On Rails Tote") }
  let(:variant) { create(:base_variant, product: product) }
  let(:line_item) { create(:line_item, variant: variant) }
  let!(:first_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }
  let!(:second_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }
  let!(:third_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }
  let!(:fourth_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }
  let!(:fifth_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }
  let!(:sixth_order) { create(:completed_order_with_totals, line_items: [line_item], user_id: first_user.id) }

  describe "methods" do
    context "#self.product_name" do
      it { expect(Spree::Marketing::FavourableProductsList.send :product_name, product.id).to eq "ruby_on_rails_tote" }
    end

    context "#self.name_text" do
      it { expect(Spree::Marketing::FavourableProductsList.send :name_text, product.id).to eq "favourable_products_list_ruby_on_rails_tote" }
    end

    context "#self.data" do
      it { expect(Spree::Marketing::FavourableProductsList.send :data).to include product.id }
    end

    context "#user_ids" do
      it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to include first_user.id }
      it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include second_user.id }
    end
  end

end
