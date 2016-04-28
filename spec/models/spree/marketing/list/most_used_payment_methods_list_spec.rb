require "spec_helper"

describe Spree::Marketing::MostUsedPaymentMethodsList, type: :model do

  let(:payment_method) { create(:credit_card_payment_method) }
  let(:entity_key) { payment_method.id }
  let(:entity_name) { payment_method.name.downcase.gsub(" ", "_") }
  let(:first_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
  let(:second_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
  let(:third_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
  let(:fourth_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
  let(:fifth_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
  let(:sixth_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:first_order) { create(:completed_order_with_totals, payments: [first_payment], user_id: first_user.id) }
  let!(:second_order) { create(:completed_order_with_totals, payments: [second_payment], user_id: first_user.id) }
  let!(:third_order) { create(:completed_order_with_totals, payments: [third_payment], user_id: first_user.id) }
  let!(:fourth_order) { create(:completed_order_with_totals, payments: [fourth_payment], user_id: first_user.id) }
  let!(:fifth_order) { create(:completed_order_with_totals, payments: [fifth_payment], user_id: first_user.id) }
  let!(:sixth_order) { create(:completed_order_with_totals, payments: [sixth_payment], user_id: first_user.id) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::MostUsedPaymentMethodsList

  describe "Constants" do
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::ENTITY_KEY).to eq "payment_method_id" }
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::MINIMUM_COUNT).to eq 5 }
    it { expect(Spree::Marketing::MostUsedPaymentMethodsList::MOST_USED_PAYMENT_METHODS_COUNT).to eq 5 }
  end

  describe "methods" do
    describe "#user_ids" do
      context "less than 5 orders" do
        let(:seventh_payment) { create(:payment, state: 'completed', payment_method: payment_method) }
        let!(:seventh_order) { create(:completed_order_with_totals, payments: [seventh_payment], user_id: second_user.id) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include second_user.id }
      end

      context "same payment method is used" do
        let(:other_payment_method) { create(:check_payment_method) }
        let(:first_other_payment) { create(:payment, state: :completed, payment_method: other_payment_method) }
        let(:second_other_payment) { create(:payment, state: :completed, payment_method: other_payment_method) }
        let(:third_other_payment) { create(:payment, state: :completed, payment_method: other_payment_method) }
        let(:fourth_other_payment) { create(:payment, state: :completed, payment_method: other_payment_method) }
        let(:fifth_other_payment) { create(:payment, state: :completed, payment_method: other_payment_method) }
        let(:sixth_other_payment) { create(:payment, state: :completed, payment_method: other_payment_method) }
        let!(:first_order_with_other_payment) { create(:completed_order_with_totals, payments: [first_other_payment], user_id: second_user.id) }
        let!(:second_order_with_other_payment) { create(:completed_order_with_totals, payments: [second_other_payment], user_id: second_user.id) }
        let!(:third_order_with_other_payment) { create(:completed_order_with_totals, payments: [third_other_payment], user_id: second_user.id) }
        let!(:fourth_order_with_other_payment) { create(:completed_order_with_totals, payments: [fourth_other_payment], user_id: second_user.id) }
        let!(:fifth_order_with_other_payment) { create(:completed_order_with_totals, payments: [fifth_other_payment], user_id: second_user.id) }
        let!(:sixth_order_with_other_payment) { create(:completed_order_with_totals, payments: [sixth_other_payment], user_id: second_user.id) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include second_user.id }
      end

      context "completed at before TIME_FRAME" do
        let(:first_other_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:second_other_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:third_other_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:fourth_other_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:fifth_other_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:sixth_other_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let!(:first_other_order) { create(:completed_order_with_totals, payments: [first_other_payment], user_id: second_user.id) }
        let!(:second_other_order) { create(:completed_order_with_totals, payments: [second_other_payment], user_id: second_user.id) }
        let!(:third_other_order) { create(:completed_order_with_totals, payments: [third_other_payment], user_id: second_user.id) }
        let!(:fourth_other_order) { create(:completed_order_with_totals, payments: [fourth_other_payment], user_id: second_user.id) }
        let!(:fifth_other_order) { create(:completed_order_with_totals, payments: [fifth_other_payment], user_id: second_user.id) }
        let!(:sixth_other_order) { create(:completed_order_with_totals, payments: [sixth_other_payment], user_id: second_user.id) }

        before do
          first_other_order.update_columns(completed_at: Time.current - 2.months)
          second_other_order.update_columns(completed_at: Time.current - 2.months)
          third_other_order.update_columns(completed_at: Time.current - 2.months)
          fourth_other_order.update_columns(completed_at: Time.current - 2.months)
          fifth_other_order.update_columns(completed_at: Time.current - 2.months)
          sixth_other_order.update_columns(completed_at: Time.current - 2.months)
        end

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include second_user.id }
      end

      context "guest user orders" do
        let(:guest_user_email) { "spree@example.com" }
        let(:first_guest_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:second_guest_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:third_guest_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:fourth_guest_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:fifth_guest_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let(:sixth_guest_payment) { create(:payment, state: :completed, payment_method: payment_method) }
        let!(:first_guest_order) { create(:completed_order_with_totals, payments: [first_guest_payment], user_id: nil, email: guest_user_email) }
        let!(:second_guest_order) { create(:completed_order_with_totals, payments: [second_guest_payment], user_id: nil, email: guest_user_email) }
        let!(:third_guest_order) { create(:completed_order_with_totals, payments: [third_guest_payment], user_id: nil, email: guest_user_email) }
        let!(:fourth_guest_order) { create(:completed_order_with_totals, payments: [fourth_guest_payment], user_id: nil, email: guest_user_email) }
        let!(:fifth_guest_order) { create(:completed_order_with_totals, payments: [fifth_guest_payment], user_id: nil, email: guest_user_email) }
        let!(:sixth_guest_order) { create(:completed_order_with_totals, payments: [sixth_guest_payment], user_id: nil, email: guest_user_email) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).send :emails).to_not include guest_user_email }
      end
    end

    describe  "#.data" do
      context "only completed payment" do
        let(:other_payment_method) { create(:check_payment_method) }
        let(:other_payment) { create(:payment, state: :pending, payment_method: other_payment_method) }
        let!(:order_with_incomplete_payment) { create(:completed_order_with_totals, payments: [other_payment], user_id: second_user.id) }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to_not include other_payment_method.id }
      end

      context "limit to MOST_USED_PAYMENT_METHODS_COUNT" do
        let(:other_payment_method) { create(:check_payment_method) }
        let(:other_payment) { create(:payment, payment_method: other_payment_method) }
        let!(:order_with_other_payment) { create(:completed_order_with_totals, payments: [other_payment], user_id: second_user.id) }

        before { Spree::Marketing::MostUsedPaymentMethodsList::MOST_USED_PAYMENT_METHODS_COUNT = 1 }

        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include payment_method.id }
        it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to_not include other_payment_method.id }
      end
    end

    context "#.payment_method_name" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :payment_method_name, payment_method.id).to eq "credit_card" }
    end

    context "#.name_text" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :name_text, payment_method.id).to eq "most_used_payment_methods_list_credit_card" }
    end
  end

end
