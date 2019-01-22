module GibbonService
  class ListService < BaseService
    attr_reader :members, :list_uid

    MEMBER_STATUS                   = { unsubscribe: 'unsubscribed', subscribe: 'subscribed' }.freeze
    DEFAULT_MEMBER_RETRIEVAL_PARAMS = { params: { status: MEMBER_STATUS[:subscribe] } }.freeze
    LIST_ATTRIBUTES                 = %i[permission_reminder email_type_option campaign_defaults contact].freeze
    DEFAULT_LIST_GENERATION_PARAMS  = SpreeMarketing::CONFIG[Rails.env].slice(*LIST_ATTRIBUTES)

    def initialize(list_uid = nil)
      @list_uid = list_uid
      @members = []
    end

    def generate_list(list_name = '')
      p "Generating List #{list_name}"
      response = gibbon.lists.create(body: { name: list_name }.merge(DEFAULT_LIST_GENERATION_PARAMS)).body
      p response
      @list_uid = response['id'] if response['id'].present?
      p "Generated List #{list_name} -- #{@list_uid}"
      response
    end

    def update_list(subscribable_emails = [], unsubscribable_uids = [])
      p "Updating List #{@list_uid}"
      unsubscribe_members(unsubscribable_uids) if unsubscribable_uids.present?
      subscribe_members(subscribable_emails) if subscribable_emails.any?
    end

    def delete_lists(list_uids = [])
      list_uids.each { |list_uid| gibbon.lists(list_uid).delete }
    end

    def subscribe_members(subscribable_emails = [])
      members_batches = subscribable_emails.in_groups_of(BATCH_COUNT, false)
      members_batches.each do |members_batch|
        p "Starting subscribe on mailchimp for members with emails #{members_batch.join(', ')}"
        members_batch.each do |email|
          params = { body: { email_address: email, status: MEMBER_STATUS[:subscribe] } }
          if member_uid = Spree::Marketing::Contact.find_by(email: email).try(:uid)
            response = gibbon.lists(@list_uid).members(member_uid).upsert(params)
          else
            response = gibbon.lists(@list_uid).members.create(params)
          end
          @members << response if response['id']
          p response
        end
        p "Finished subscribe on mailchimp for members with emails #{members_batch.join(', ')}"
      end
      @members
    end

    def unsubscribe_members(unsubscribable_uids = [])
      members_batches = unsubscribable_uids.in_groups_of(BATCH_COUNT, false)
      members_batches.each do |members_batch|
        p "Starting unsubscribe on mailchimp for members with uids #{members_batch.join('-')}"
        members_batch.each do |uid|
          response = gibbon.lists(@list_uid).members(uid).update(body: { status: MEMBER_STATUS[:unsubscribe] })
          p response
        end
        p "Finished unsubscribe on mailchimp for members with uids #{members_batch.join(', ')}"
      end
    end

    private
      def retrieve_members
        p "retrieving members for list #{@list_uid}"
        @members = gibbon.lists(@list_uid).members.retrieve(DEFAULT_MEMBER_RETRIEVAL_PARAMS)['members']
      end
  end
end
