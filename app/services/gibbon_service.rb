class GibbonService

  attr_reader :members, :list_uid

  MEMBER_STATUS                   = { unsubscribe: 'unsubscribe', subscribe: 'subscribe' }
  DEFAULT_MEMBER_RETRIEVAL_PARAMS = { params: { 'status': MEMBER_STATUS[:subscribe] } }
  LIST_ATTRIBUTES                 = [:permission_reminder, :email_type_option, :campaign_defaults, :contact]
  BATCH_COUNT                     = 50
  RETRY_COUNT                     = 5
  TIME_DELAY                      = 500

  def self.gibbon
    @gibbon ||= Gibbon::Request.new
  end

  def initialize(list_uid = nil)
    @list_uid = list_uid
    retrieve_members if @list_uid
  end

  def generate_list(list_name = '')
    response = self.class.gibbon.lists.create(body: { name: list_name }.merge(default_list_generation_params))
    @list_uid = response['id'] if response['id'].present?
    response
  end

  def update_list
    @list_uid = @list_uids.first
    unsubscribe_existing_members
    subscribe_new_members
    retrieve_members
  end

  def subscribe_members(members_emails = [])
    members_batches = members_emails.in_groups_of(BATCH_COUNT, false)
    members_batches.each do |members_batch|
      @new_members_emails = members_batch
      response = self.class.gibbon.batches.create(body: { operations: member_operations_list_to_generate })
      tail_batch_response(response['batch_id'])
    end
    retrieve_members
  end

  def unsubscribe_members(list_uid = nil)
    members_batches = @members.in_groups_of(BATCH_COUNT, false)
    members_batches.each do |members_batch|
      response = self.class.gibbon.batches.create(body: { operations: member_operations_list_to_unsubscribe })
      tail_batch_response(response['batch_id'])
    end
  end

  private

    def tail_batch_response(batch_id)
      unless check_batch_response(batch_id, RETRY_COUNT)
        raise Gibbon::MailChimpError.new("Failed Batch #{ batch_id } --- #{ response.body }")
      end
    end

    def check_batch_response(batch_id, retry_count)
      batch_response = self.class.gibbon.batches(batch_id).retrieve

      if batch_response['status'] == 'finished'
        true
      else
        if retry_count > 0
          sleep(TIME_DELAY)
          check_batch_response(batch_id, --retry_count)
        else
          false
        end
      end
    end

    def retrieve_members
      @members = self.class.gibbon.lists(@list_uid).members.retrieve(DEFAULT_MEMBER_RETRIEVAL_PARAMS)
    end

    def members_uids
      @members.map { |member| member[:uid] }
    end

    def member_operations_list_to_unsubscribe
      members_uids.select do |uid|
        {
          method: "PATCH",
          path: "lists/#{ @list_uid }/members/#{ uid }",
          body: "{\"status\":\"#{ MEMBER_STATUS[:unsubscribe] }\"}"
        }
      end
    end

    def member_operations_list_to_generate
      @new_members_emails.select do |email_address|
        {
          method: "POST",
          path: "lists/#{ @list_uid }/members",
          body: "{\"email_address\": \"#{ email_address }\",\"status\":\"#{ MEMBER_STATUS[:subscribe] }\"}"
        }
      end
    end

    def default_list_generation_params
      SpreeMarketing::DEFAULT_LIST_GENERATION_PARAMS[Rails.env].slice(*LIST_ATTRIBUTES)
    end
end
