Spree::Order.class_eval do
  scope :without_guest_user, -> { where.not(user_id: nil) }
end
