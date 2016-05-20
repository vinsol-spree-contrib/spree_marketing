require "spec_helper"

describe Spree::Marketing::Recipient, type: :model do
  let(:campaign_recipients_user) { create(:user) }
  let(:contact) { create(:marketing_contact, user: campaign_recipients_user) }
  let(:one_day_earlier_time) { Time.current - 1.day }
  let(:campaign) { build(:marketing_campaign, scheduled_at: one_day_earlier_time) }
  let(:recipient) { create(:marketing_recipient, contact: contact, campaign: campaign) }

  before do
    allow(campaign).to receive_messages(enqueue_update: nil)
    campaign.recipients << recipient
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:campaign) }
    it { is_expected.to validate_presence_of(:contact) }
    it { is_expected.to validate_uniqueness_of(:contact_id).scoped_to(:campaign_id) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:campaign).class_name("Spree::Marketing::Campaign") }
    it { is_expected.to belong_to(:contact).class_name("Spree::Marketing::Contact") }
  end

  describe 'Scopes' do
    context '.email_unopened' do
      let(:recipient_with_email_opened_at) { create(:marketing_recipient, campaign: campaign, email_opened_at: Time.current) }
      let(:recipient_without_email_opened_at) { create(:marketing_recipient, campaign: campaign, email_opened_at: nil) }

      it { expect(Spree::Marketing::Recipient.email_unopened).to include recipient_without_email_opened_at }
      it { expect(Spree::Marketing::Recipient.email_unopened).to_not include recipient_with_email_opened_at }
    end

    context '.with_emails' do
      let(:recipient_with_contact_email) { recipient }
      let(:recipient_without_contact_email) { create(:marketing_recipient, campaign: campaign) }
      let(:recipients_with_email) { Spree::Marketing::Recipient.with_emails([contact.email]) }

      it { expect(recipients_with_email).to include recipient_with_contact_email }
      it { expect(recipients_with_email).to_not include recipient_without_contact_email }
    end
  end

  describe 'Delegates' do
    it { is_expected.to delegate_method(:uid).to(:contact).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:contact).with_prefix(true) }
    it { is_expected.to delegate_method(:user).to(:contact).with_prefix(true) }
  end

  describe '.update_email_opened_at' do
    let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, last_open: Time.current }.with_indifferent_access] }

    before do
      campaign.recipients.includes(:contact).update_email_opened_at(recipients_data)
    end

    it 'updates unopened recipients\'s email_opened_at' do
      expect(recipient.reload.email_opened_at).to eq(recipients_data[0][:last_open])
    end
  end

  describe '.user_ids' do
    it 'returns user_ids corresponding to the recipients' do
      expect(campaign.recipients.user_ids).to include campaign_recipients_user.id
    end
  end

  describe '.activity_data' do
    let!(:campaign_user_first_page_event) { create(:marketing_page_event, actor: campaign_recipients_user) }
    let!(:campaign_user_second_page_event) { create(:marketing_page_event, actor: campaign_recipients_user, created_at: Time.current + 2.hour) }
    let(:log_ins_data_hash) { { campaign_recipients_user.email=>campaign_user_first_page_event.created_at } }

    it 'returns hash of recipients emails and their first activity in the category passed as an argument' do
      expect(campaign.recipients.activity_data("log_ins", campaign.scheduled_at)).to eq log_ins_data_hash
    end
  end

  describe '.log_ins_data' do
    let!(:campaign_user_first_page_event) { create(:marketing_page_event, actor: campaign_recipients_user) }
    let!(:campaign_user_second_page_event) { create(:marketing_page_event, actor: campaign_recipients_user) }
    let(:log_ins_data_hash) { { campaign_recipients_user.email=>campaign_user_first_page_event.created_at } }

    context 'with correct method flow' do
      it 'returns hash of recipients emails and time of their first log in' do
        expect(campaign.recipients.log_ins_data(campaign.scheduled_at)).to include log_ins_data_hash
      end
    end

    context 'with page events by guest users' do
      let!(:guest_user_page_event) { create(:marketing_page_event, actor: nil) }
      it 'returns hash of registered recipients emails and their time of first log in' do
        expect(campaign.recipients.log_ins_data(campaign.scheduled_at).keys).to_not include nil
      end
    end

    context 'with page events of campaign users before campaign scheduled at' do
      let(:user_with_activity_before_campaign_sheduled_at) { create(:user) }
      let(:user_with_activity_before_campaign_sheduled_at_contact) { create(:marketing_contact, user: user_with_activity_before_campaign_sheduled_at) }
      let!(:user_with_activity_before_campaign_sheduled_at_recipient) { create(:marketing_recipient, campaign: campaign, contact: user_with_activity_before_campaign_sheduled_at_contact) }
      let(:time_before_campaign_scheduled_at) { Time.current - 2.day }
      let!(:user_with_activity_before_campaign_sheduled_at_page_event) { create(:marketing_page_event, actor: user_with_activity_before_campaign_sheduled_at, created_at: time_before_campaign_scheduled_at) }
      let(:user_with_activity_before_campaign_sheduled_at_hash) { { user_with_activity_before_campaign_sheduled_at.email=>user_with_activity_before_campaign_sheduled_at_page_event.created_at } }

      it 'returns hash of recipients emails and time of their first log in(only after campaign scheduled at)' do
        expect(campaign.recipients.log_ins_data(campaign.scheduled_at)).to_not include user_with_activity_before_campaign_sheduled_at_hash
      end
    end

    context 'with other users having page events not belonging to that campaign' do
      let(:user_not_belonging_to_campaign) { create(:user) }
      let!(:user_not_belonging_to_campaign_page_event) { create(:marketing_page_event, actor: user_not_belonging_to_campaign) }
      let(:user_not_belonging_to_campaign_hash) { { user_not_belonging_to_campaign.email=>user_not_belonging_to_campaign_page_event.created_at } }

      it 'returns hash of only recipients emails and time of their first log in' do
        expect(campaign.recipients.log_ins_data(campaign.scheduled_at)).to_not include user_not_belonging_to_campaign_hash
      end
    end
  end

  describe '.cart_additions_data' do
    let(:campaign_recipients_user_order) { create(:order, user: campaign_recipients_user) }
    let!(:campaign_user_cart_addition_event) { create(:cart_addition_event, actor: campaign_recipients_user_order) }
    let(:cart_additions_data_hash) { { campaign_recipients_user.email=>campaign_user_cart_addition_event.created_at } }

    context 'with correct method flow' do
      it 'returns hash of recipients emails and to time of their first cart addition activity' do
        expect(campaign.recipients.cart_additions_data(campaign.scheduled_at)).to include cart_additions_data_hash
      end
    end

    context 'with cart addition events by guest users' do
      let(:guest_user_order) { create(:order, user_id: nil) }
      let!(:guest_user_cart_addition_event) { create(:cart_addition_event, actor: guest_user_order) }

      it 'returns hash of registered recipients emails and time of first cart addition activity' do
        expect(campaign.recipients.cart_additions_data(campaign.scheduled_at).keys).to_not include nil
      end
    end

    context 'with page events of recipients before campaign scheduled at' do
      let(:user_with_activity_before_campaign_sheduled_at) { create(:user) }
      let(:user_with_activity_before_campaign_sheduled_at_order) { create(:order, user: user_with_activity_before_campaign_sheduled_at) }
      let(:user_with_activity_before_campaign_sheduled_at_contact) { create(:marketing_contact, user: user_with_activity_before_campaign_sheduled_at) }
      let!(:user_with_activity_before_campaign_sheduled_at_recipient) { create(:marketing_recipient, campaign: campaign, contact: user_with_activity_before_campaign_sheduled_at_contact) }
      let(:time_before_campaign_scheduled_at) { Time.current - 2.day }
      let!(:user_with_activity_before_campaign_sheduled_at_cart_addition_event) { create(:cart_addition_event, actor: user_with_activity_before_campaign_sheduled_at_order, created_at: time_before_campaign_scheduled_at) }
      let(:user_with_activity_before_campaign_sheduled_at_hash) { { user_with_activity_before_campaign_sheduled_at.email=>user_with_activity_before_campaign_sheduled_at_cart_addition_event.created_at } }

      it 'returns hash of recipients emails and time of first cart addition activity(only after campaign scheduled at)' do
        expect(campaign.recipients.cart_additions_data(campaign.scheduled_at)).to_not include user_with_activity_before_campaign_sheduled_at_hash
      end
    end

    context 'with other users having page events not belonging to those recipients' do
      let(:user_not_belonging_to_campaign) { create(:user) }
      let(:user_not_belonging_to_campaign_order) { create(:order, user: user_not_belonging_to_campaign) }
      let!(:user_not_belonging_to_campaign_cart_addition_event) { create(:cart_addition_event, actor: user_not_belonging_to_campaign_order) }
      let(:user_not_belonging_to_campaign_hash) { { user_not_belonging_to_campaign.email=>user_not_belonging_to_campaign_cart_addition_event.created_at } }

      it 'returns hash of only recipients emails and time of their first cart addition activity' do
        expect(campaign.recipients.cart_additions_data(campaign.scheduled_at)).to_not include user_not_belonging_to_campaign_hash
      end
    end

    context 'with recipients having cart activity other than addition' do
      let(:user_with_cart_activity_other_than_add) { create(:user) }
      let(:user_with_cart_activity_other_than_add_order) { create(:order, user: user_with_cart_activity_other_than_add) }
      let!(:user_with_cart_activity_other_than_add_cart_activity) { create(:cart_addition_event, activity: :remove, actor: user_with_cart_activity_other_than_add_order) }
      let(:user_with_cart_activity_other_than_add_hash) { { user_with_cart_activity_other_than_add.email=>user_with_cart_activity_other_than_add_cart_activity.created_at } }

      it 'returns hash of recipients emails and time of their first cart addition activity' do
        expect(campaign.recipients.cart_additions_data(campaign.scheduled_at)).to_not include user_with_cart_activity_other_than_add_hash
      end
    end
  end

  describe '.purchases_data' do
    let!(:completed_order_of_campaigns_user) { create(:completed_order_with_totals, user: campaign_recipients_user) }
    let(:purchases_data_hash) { { campaign_recipients_user.email=>completed_order_of_campaigns_user.completed_at } }

    context 'with correct method flow' do
      it 'returns hash of recipients emails and time of their first purchase' do
        expect(campaign.recipients.purchases_data(campaign.scheduled_at)).to include purchases_data_hash
      end
    end

    context 'with guest user completed orders' do
      let!(:guest_user_completed_order) { create(:completed_order_with_totals, user_id: nil) }

      it 'returns hash of registered recipients emails and time of their first purchase' do
        expect(campaign.recipients.purchases_data(campaign.scheduled_at).keys).to_not include nil
      end
    end

    context 'with orders of users not belonging to that campaign' do
      let(:user_not_belonging_to_campaign) { create(:user) }
      let!(:user_not_belonging_to_campaign_completed_order) { create(:completed_order_with_totals, user: user_not_belonging_to_campaign) }
      let(:user_not_belonging_to_campaign_hash) { { user_not_belonging_to_campaign.email=>user_not_belonging_to_campaign_completed_order.completed_at } }

      it 'returns hash of only recipients emails and time of their first purchase' do
        expect(campaign.recipients.purchases_data(campaign.scheduled_at)).to_not include user_not_belonging_to_campaign_hash
      end
    end

    context 'with orders of users belonging to campaign before campaign scheduled_at' do
      let(:campaign_recipients_user_having_old_completed_order) { create(:user) }
      let(:time_before_campaign_scheduled_at) { Time.current - 2.day }
      let!(:old_completed_order) { create(:order_with_promotion, :with_custom_completed_at, completed_at: time_before_campaign_scheduled_at, user: campaign_recipients_user_having_old_completed_order) }
      let(:campaign_recipients_user_having_old_completed_order_hash) { { campaign_recipients_user_having_old_completed_order.email=>old_completed_order.completed_at } }

      it 'returns hash of recipients emails and time of their first purchase(only after campaign scheduled at)' do
        expect(campaign.recipients.purchases_data(campaign.scheduled_at)).to_not include campaign_recipients_user_having_old_completed_order_hash
      end
    end
  end

  describe '.product_views_data' do
    let!(:campaign_user_product_view_event) { create(:marketing_product_view_event, actor: campaign_recipients_user) }
    let(:product_views_data_hash) { { campaign_recipients_user.email=>campaign_user_product_view_event.created_at } }

    context 'with correct method flow' do
      it 'returns hash of recipients emails and time of their first product view activity' do
        expect(campaign.recipients.product_views_data(campaign.scheduled_at)).to include product_views_data_hash
      end
    end

    context 'with page events by guest users' do
      let!(:guest_user_product_view_event) { create(:marketing_product_view_event, actor: nil) }
      it 'returns hash of registered recipients emails and time of their first product view activity' do
        expect(campaign.recipients.product_views_data(campaign.scheduled_at).keys).to_not include nil
      end
    end

    context 'with page events of campaign users before campaign scheduled at' do
      let(:user_with_activity_before_campaign_sheduled_at) { create(:user) }
      let(:user_with_activity_before_campaign_sheduled_at_contact) { create(:marketing_contact, user: user_with_activity_before_campaign_sheduled_at) }
      let!(:user_with_activity_before_campaign_sheduled_at_recipient) { create(:marketing_recipient, campaign: campaign, contact: user_with_activity_before_campaign_sheduled_at_contact) }
      let(:time_before_campaign_scheduled_at) { Time.current - 2.day }
      let!(:user_with_activity_before_campaign_sheduled_at_product_view_event) { create(:marketing_product_view_event, actor: user_with_activity_before_campaign_sheduled_at, created_at: time_before_campaign_scheduled_at) }
      let(:user_with_activity_before_campaign_sheduled_at_hash) { { user_with_activity_before_campaign_sheduled_at.email=>user_with_activity_before_campaign_sheduled_at_product_view_event.created_at } }

      it 'returns hash of recipients emails and time of their first product view activity(only after campaign scheduled at)' do
        expect(campaign.recipients.product_views_data(campaign.scheduled_at)).to_not include user_with_activity_before_campaign_sheduled_at_hash
      end
    end

    context 'with other users having page events not belonging to that campaign' do
      let(:user_not_belonging_to_campaign) { create(:user) }
      let!(:user_not_belonging_to_campaign_product_view_event) { create(:marketing_product_view_event, actor: user_not_belonging_to_campaign) }
      let(:user_not_belonging_to_campaign_hash) { { user_not_belonging_to_campaign.email=>user_not_belonging_to_campaign_product_view_event.created_at } }

      it 'returns hash of only recipients emails and time of their first product view activity' do
        expect(campaign.recipients.product_views_data(campaign.scheduled_at)).to_not include user_not_belonging_to_campaign_hash
      end
    end

    context 'with users belonging to campaign having view events for targets other than Spree::Product' do
      let(:user_with_view_event_of_other_than_product) { create(:user) }
      let(:user_with_view_event_of_other_than_product_contact) { create(:marketing_contact, user: user_with_view_event_of_other_than_product) }
      let!(:user_with_view_event_of_other_than_product_recipient) { create(:marketing_recipient, campaign: campaign, contact: user_with_view_event_of_other_than_product_contact) }
      let!(:user_with_view_event_of_other_than_product_product_view_event) { create(:marketing_product_view_event, actor: user_with_view_event_of_other_than_product, target: nil) }
      let(:user_with_view_event_of_other_than_product_hash) { { user_with_view_event_of_other_than_product.email=>user_with_view_event_of_other_than_product_product_view_event.created_at } }

      it 'returns hash of recipients emails and time of their first only product view activity' do
        expect(campaign.recipients.product_views_data(campaign.scheduled_at)).to_not include user_with_view_event_of_other_than_product_hash
      end
    end

    context 'with users having page events of other than view type' do
      let(:user_with_page_event_of_other_than_view) { create(:user) }
      let(:user_with_page_event_of_other_than_view_contact) { create(:marketing_contact, user: user_with_page_event_of_other_than_view) }
      let!(:user_with_page_event_of_other_than_view_recipient) { create(:marketing_recipient, contact: user_with_page_event_of_other_than_view_contact, campaign: campaign) }
      let!(:user_with_page_event_of_other_than_view_product_event) { create(:marketing_product_view_event, actor: user_with_page_event_of_other_than_view, activity: :index) }
      let!(:user_with_page_event_of_other_than_view_hash) { { user_with_page_event_of_other_than_view.email=>user_with_page_event_of_other_than_view_product_event.created_at } }

      it 'returns hash of recipients emails and time of their first product only view type activity' do
        expect(campaign.recipients.product_views_data(campaign.scheduled_at)).to_not include user_with_page_event_of_other_than_view_hash
      end
    end
  end

end
