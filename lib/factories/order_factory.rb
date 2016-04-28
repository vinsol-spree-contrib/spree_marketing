FactoryGirl.define do

  factory :order_with_given_payment_method, parent: :completed_order_with_totals, class: Spree::Order do
    transient do
      payment_method nil
    end

    after(:create) do |order, evaluator|
      payment = create(:payment, amount: order.total, state: :completed, payment_method: evaluator.payment_method)
      order.payments << payment
      order.user = evaluator.user
      order.save!
    end

    trait :with_custom_completed_at do
      transient do
        completed_at nil
      end

      after(:create) do |order, evaluator|
        order.update_columns(completed_at: evaluator.completed_at)
      end
    end
  end

  factory :guest_user_order_with_given_payment_method, parent: :completed_order_with_totals, class: Spree::Order do
    transient do
      payment_method nil
    end

    after(:create) do |order, evaluator|
      payment = create(:payment, amount: order.total, payment_method: evaluator.payment_method)
      order.payments << payment
      order.update(user: nil)
    end
  end

  factory :order_with_given_completed_at_and_payment_method, parent: :order_with_given_payment_method, class: Spree::Order do
    transient do
      completed_at nil
    end

    after(:create) do |order, evaluator|
      order.update_columns(completed_at: evaluator.completed_at)
    end
  end

end
