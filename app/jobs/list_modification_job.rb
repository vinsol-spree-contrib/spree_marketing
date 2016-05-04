class ListModificationJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(list_id, subscribable_emails, unsubscribable_uids)
    list = Spree::Marketing::List.find_by(id: list_id)
    gibbon_service = GibbonService::ListService.new(list.uid)
    contacts_data = gibbon_service.update_list(subscribable_emails, unsubscribable_uids) || []
    unsubscribable_ids = Spree::Marketing::Contact.where(uid: unsubscribable_uids).pluck(:id)
    list.contacts_lists.with_contact_ids(unsubscribable_ids).destroy_all
    list.populate(contacts_data)
  end
end
