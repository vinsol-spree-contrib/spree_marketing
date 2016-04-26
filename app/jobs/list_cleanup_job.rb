class ListCleanupJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(list_uids = [])
    gibbon_service = GibbonService.new
    gibbon_service.delete_lists(list_uids)
    Spree::Marketing::List.where(uid: list_uids).destroy_all
  end
end
