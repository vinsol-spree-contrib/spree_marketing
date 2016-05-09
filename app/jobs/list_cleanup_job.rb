class ListCleanupJob < ActiveJob::Base
  include ::MailchimpErrorHandler

  queue_as :default

  def perform(list_uids = [])
    gibbon_service = GibbonService::ListService.new
    gibbon_service.delete_lists(list_uids)
    Spree::Marketing::List.where(uid: list_uids).destroy_all
  end

end
