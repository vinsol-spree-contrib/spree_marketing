FactoryGirl.define do
  factory :user_with_completed_orders, parent: :user, class: Spree.user_class do

    trait :with_given_payment_method do
      transient do
        orders_count 5
        payment_method nil
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:order_with_given_payment_method, evaluator.orders_count, payment_method: evaluator.payment_method, user: user)
      end
    end

    trait :with_custom_completed_at do
      transient do
        completed_at nil
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:order_with_given_payment_method, evaluator.orders_count, :with_custom_completed_at, payment_method: evaluator.payment_method, user: user, completed_at: evaluator.completed_at)
      end
    end
  end


end
