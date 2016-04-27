require "spec_helper"

describe Spree::Marketing::MostUsedPaymentMethodsList, type: :model do

  let(:payment_method) { create(:credit_card_payment_method) }
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

  describe "methods" do
    context "#user_ids" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to include first_user.id }
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.new(payment_method_id: payment_method.id).user_ids).to_not include second_user.id }
    end

    context "#self.data" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :data).to include payment_method.id }
    end

    context "#self.payment_method_name" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :payment_method_name, payment_method.id).to eq "credit_card" }
    end

    context "#self.name_text" do
      it { expect(Spree::Marketing::MostUsedPaymentMethodsList.send :name_text, payment_method.id).to eq "most_used_payment_methods_list_credit_card" }
    end
  end

end
