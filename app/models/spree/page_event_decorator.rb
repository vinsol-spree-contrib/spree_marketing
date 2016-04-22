Spree::PageEvent.class_eval do
  scope :of_registered_users, -> { where.not(actor_id: nil) }
end
