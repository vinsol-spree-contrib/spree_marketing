Spree::PageEvent.class_eval do
  scope :without_guest_user, -> { where.not(actor_id: nil) }
end
