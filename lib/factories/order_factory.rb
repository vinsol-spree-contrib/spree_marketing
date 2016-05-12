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

    trait :incomplete_payment do
      after(:create) do |order, evaluator|
        order.payments.update_all(state: :pending)
      end
    end
  end

  factory :order_with_given_billing_state, parent: :completed_order_with_totals, class: Spree::Order do
    transient do
      state nil
    end

    after(:create) do |order, evaluator|
      address = create(:address, state: evaluator.state)
      order.update(bill_address: address)
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

  factory :order_with_promotion, parent: :completed_order_with_totals, class: Spree::Order do
    after(:create) do |order, evaluator|
      promotion = create(:promotion_with_order_adjustment)
      order.promotions << promotion
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

  factory :order_with_given_product, parent: :completed_order_with_totals, class: Spree::Order do
    transient do
      product nil
    end

    after(:create) do |order, evaluator|
      variant = create(:base_variant, product: evaluator.product)
      line_item = create(:line_item, variant: variant)
      order.line_items << line_item
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

  factory :completed_order_with_custom_completion_time, parent: :completed_order_with_totals, class: Spree::Order do
    transient do
      completed_at nil
    end

    after(:create) do |order, evaluator|
      order.update_columns(completed_at: evaluator.completed_at)
    end
  end

end
