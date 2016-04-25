class ListCleanupJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(lists)
    gibbon_service = GibbonService.new
    contacts_data = gibbon_service.delete_lists(lists.pluck(:uid))
    lists.destroy_all
  end
end
