class ListModificationJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(list, subscribable_emails, unsubscribable_uids)
    gibbon_service = GibbonService.new(list.uid)
    contacts_data = gibbon_service.update_list(subscribable_emails, unsubscribable_uids) || []
    list.contacts_lists.unsubscribable(unsubscribable_uids).destroy_all
    contacts_data.each do |contact_data|
      contact = Spree::Marketing::Contact.find_or_create_by(email: contact_data['email_address'],
                                            uid: contact_data['id'],
                                            mailchimp_id: contact_data['unique_email_id'])
      list.contacts << contact
    end
  end
end
