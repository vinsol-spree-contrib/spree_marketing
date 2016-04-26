class ListGenerationJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(list_name, emails, list_class_name)
    gibbon_service = GibbonService.new
    list_data = gibbon_service.generate_list(list_name)
    list = list_class_name.constantize.create(uid: list_data['id'], name: list_data['name'])
    if emails.present?
      contacts_data = gibbon_service.subscribe_members(emails)
      p contacts_data
      if contacts_data.present?
        contacts_data.each do |contact_data|
          contact = Spree::Marketing::Contact.find_or_create_by(email: contact_data['email_address'],
                                                uid: contact_data['id'],
                                                mailchimp_id: contact_data['unique_email_id'])
          list.contacts << contact
        end
      end
    end
  end
end
