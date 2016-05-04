require "spec_helper"

describe Spree::Marketing::MostUsedPaymentMethodsList, type: :model do

  let(:payment_method) { create(:credit_card_payment_method) }
  let(:entity_key) { payment_method.id }
  let(:entity_name) { payment_method.name.downcase.gsub(" ", "_") }
  let!(:user_with_more_than_5_completed_orders) { create(:user_with_completed_orders, :with_given_payment_method, payment_method: payment_method, orders_count: 6) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::MostUsedPaymentMethodsList

  describe "Constants" do
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::ENTITY_KEY).to eq "entity_id" }
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::MINIMUM_COUNT).to eq 5 }
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::MOST_USED_PAYMENT_METHODS_COUNT).to eq 5 }
  end

  describe "methods" do
    describe "#user_ids" do
      context "with users having greater than 5 orders" do
        let!(:user_with_less_than_5_completed_orders) { create(:user_with_completed_orders, :with_given_payment_method, orders_count: 4, payment_method: payment_method) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include user_with_more_than_5_completed_orders.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include user_with_less_than_5_completed_orders.id }
      end

      context "with users having greater than 5 orders orders with selected payment method" do
        let(:other_payment_method) { create(:check_payment_method) }
        let!(:user_with_more_than_5_completed_orders_with_other_payment_method) { create(:user_with_completed_orders, :with_given_payment_method, orders_count: 6, payment_method: other_payment_method) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include user_with_more_than_5_completed_orders.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include user_with_more_than_5_completed_orders_with_other_payment_method.id }
      end

      context "with users having greater than 5 orders completed before TIME_FRAME" do
        let(:timestamp) { Time.current - 2.months }
        let(:user_having_more_than_5_old_completed_orders) { create(:user_with_completed_orders, :with_given_payment_method, :with_custom_completed_at, completed_at: timestamp, orders_count: 6, payment_method: payment_method) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include user_with_more_than_5_completed_orders.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include user_having_more_than_5_old_completed_orders.id }
      end

      context "when user is not registered having greater than 5 orders" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_having_more_than_5_completed_order_with_given_payment_method) { create_list(:guest_user_order_with_given_payment_method, 6, email: guest_user_email, payment_method: payment_method) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).send :emails).to_not include guest_user_email }
      end
    end

    describe  ".data" do
      context "with completed orders having completed payment" do
        let(:other_payment_method) { create(:check_payment_method) }
        let!(:order_with_incomplete_payment) { create(:order_with_given_payment_method, :incomplete_payment, payment_method: other_payment_method) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to_not include other_payment_method.id }
      end

      context "limit to MOST_USED_PAYMENT_METHODS_COUNT" do
        let(:second_payment_method) { create(:credit_card_payment_method) }
        let(:third_payment_method) { create(:credit_card_payment_method) }
        let(:fourth_payment_method) { create(:credit_card_payment_method) }
        let(:fifth_payment_method) { create(:credit_card_payment_method) }
        let(:sixth_payment_method) { create(:credit_card_payment_method) }
        let!(:completed_orders_with_second_payment_method) { create_list(:order_with_given_payment_method, 6, payment_method: second_payment_method) }
        let!(:completed_orders_with_third_payment_method) { create_list(:order_with_given_payment_method, 6, payment_method: third_payment_method) }
        let!(:completed_orders_with_fourth_payment_method) { create_list(:order_with_given_payment_method, 6, payment_method: fourth_payment_method) }
        let!(:completed_orders_with_fifth_payment_method) { create_list(:order_with_given_payment_method, 6, payment_method: fifth_payment_method) }
        let!(:completed_orders_with_sixth_payment_method) { create_list(:order_with_given_payment_method, 1, payment_method: sixth_payment_method) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include second_payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include third_payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include fourth_payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include fifth_payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to_not include sixth_payment_method.id }
      end
    end

    context ".payment_method_name" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :payment_method_name, payment_method.id).to eq "credit_card" }
    end

    context ".name_text" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :name_text, payment_method.id).to eq "most_used_payment_methods_list_credit_card" }
    end
  end

end
