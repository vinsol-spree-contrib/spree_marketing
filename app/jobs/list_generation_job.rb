class ListGenerationJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(list_name, emails, list_type = nil)
    gibbon_service = GibbonService.new
    list_data = gibbon_service.generate_list(list_name)
    list_class = "spree/marketing/#{ list_type || list_name }".classify.constantize
    list = list_class.create(uid: list_data['id'], name: list_data['name'])
    contacts_data = gibbon_service.subscribe_members(emails)['members']
    contacts_data.each do |contact_data|
      list.contacts << Spree::Contact.build(email: contact_data['email_address'],
                                            uid: contact_data['id'],
                                            mailchimp_id: contact_data['unique_email_id'])
    end
    list.save
  end
end
