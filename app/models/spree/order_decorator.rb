Spree::Order.class_eval do
  scope :of_registered_users, -> { where.not(user_id: nil) }
end
