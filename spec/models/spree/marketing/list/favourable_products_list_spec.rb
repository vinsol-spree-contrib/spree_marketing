require "spec_helper"

describe Spree::Marketing::FavourableProductsList, type: :model do

  let(:user_with_orders_having_given_product) { create(:user) }
  let(:product) { create(:product, name: "Ruby On Rails Tote") }
  let(:entity_key) { product.id }
  let(:entity_name) { product.name.downcase.gsub(" ", "_") }
  let!(:orders_having_given_product) { create_list(:order_with_given_product, 2, user: user_with_orders_having_given_product, product: product) }

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
        let(:second_product) { create(:product, name: "Product 2") }
        let(:third_product) { create(:product, name: "Product 3") }
        let(:fourth_product) { create(:product, name: "Product 4") }
        let(:fifth_product) { create(:product, name: "Product 5") }
        let(:sixth_product) { create(:product, name: "Product 6") }
        let(:seventh_product) { create(:product, name: "Product 7") }
        let(:eighth_product) { create(:product, name: "Product 8") }
        let(:ninth_product) { create(:product, name: "Product 9") }
        let(:tenth_product) { create(:product, name: "Product 10") }
        let(:eleventh_product) { create(:product, name: "Product 11") }

        let!(:orders_having_second_product) { create_list(:order_with_given_product, 2, product: second_product) }
        let!(:orders_having_third_product) { create_list(:order_with_given_product, 2, product: third_product) }
        let!(:orders_having_fourth_product) { create_list(:order_with_given_product, 2, product: fourth_product) }
        let!(:orders_having_fifth_product) { create_list(:order_with_given_product, 2, product: fifth_product) }
        let!(:orders_having_sixth_product) { create_list(:order_with_given_product, 2, product: sixth_product) }
        let!(:orders_having_seventh_product) { create_list(:order_with_given_product, 2, product: seventh_product) }
        let!(:orders_having_eighth_product) { create_list(:order_with_given_product, 2, product: eighth_product) }
        let!(:orders_having_ninth_product) { create_list(:order_with_given_product, 2, product: ninth_product) }
        let!(:orders_having_tenth_product) { create_list(:order_with_given_product, 2, product: tenth_product) }
        let!(:orders_having_eleventh_product) { create_list(:order_with_given_product, 1, product: eleventh_product) }

        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include second_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include third_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include fourth_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include fifth_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include sixth_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include seventh_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include eighth_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include ninth_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to include tenth_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.send :data).to_not include eleventh_product.id }
      end
    end

    describe "#user_ids" do
      context "method flow" do
        let!(:another_user) { create(:user) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to include user_with_orders_having_given_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include another_user.id }
      end

      context "when user is not registered" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_complete_order) { create(:order_with_given_product, product: product, email: guest_user_email, user_id: nil) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).send :emails).to_not include guest_user_complete_order.email }
      end

      context "when order is completed before TIME_FRAME" do
        let(:registered_user) { create(:user) }
        let(:timestamp) { Time.current - 2.months }
        let!(:registered_user_old_complete_order) { create(:order_with_given_product, :with_custom_completed_at, user: registered_user, product: product, completed_at: timestamp) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include registered_user.id }
      end

      context "when other product orders also exists" do
        let(:user_with_order_having_other_product) { create(:user) }
        let(:other_product) { create(:product, name: "Sample") }
        let!(:other_product_order) { create(:order_with_given_product, product: other_product, user_id: user_with_order_having_other_product.id) }

        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to_not include user_with_order_having_other_product.id }
        it { expect(Spree::Marketing::FavourableProductsList.new(product_id: product.id).user_ids).to include user_with_orders_having_given_product.id }
      end
    end
  end

end
