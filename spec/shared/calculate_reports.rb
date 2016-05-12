RSpec.shared_examples 'calculate_reports' do

  let(:user_with_successful_purchase) { create(:user) }
  let(:user_with_product_view_event) { create(:user) }
  let(:user_with_cart_addition_event) { create(:user) }
  let(:user_with_login_event) { create(:user) }
  let(:contact_with_successful_purchase) { create(:marketing_contact, email: user_with_successful_purchase.email) }
  let(:contact_with_product_view_event) { create(:marketing_contact, email: user_with_product_view_event.email) }
  let(:contact_with_cart_addition_event) { create(:marketing_contact, email: user_with_cart_addition_event.email) }
  let(:contact_with_login_event) { create(:marketing_contact, email: user_with_login_event.email) }
  let(:new_users_list) { create(:new_users_list) }
  let(:timestamp) { campaign_with_recepients.scheduled_at - 1.day }
  let!(:campaign_with_recepients) { create(:marketing_campaign, contacts: [contact_with_successful_purchase, contact_with_product_view_event, contact_with_cart_addition_event, contact_with_login_event], list: new_users_list) }

  describe "#product_views_by" do
    context "when guest user views product" do
      let!(:guest_user_product_view) { create(:marketing_product_view_event, actor: nil) }

      it "returns emails of users which are not guest users" do
        expect(campaign_with_recepients.product_views_by.size).to eq 0
      end
    end

    context "when product is viewed before scheduled time" do
      let!(:product_view_event) { create(:marketing_product_view_event, actor: user_with_product_view_event) }
      let!(:old_product_view_event) { create(:marketing_product_view_event, actor: user_with_successful_purchase, created_at: timestamp) }

      it "returns emails which includes email of user_with_product_view_event" do
        expect(campaign_with_recepients.product_views_by).to include user_with_product_view_event.email
      end
      it "returns emails which do not include email of user with old product view event" do
        expect(campaign_with_recepients.product_views_by).to_not include user_with_successful_purchase.email
      end
    end

    context "when there are product view events of users other than Spree.user_class type" do
      let(:other_user_type_id) { 9 }
      let(:other_user_type_email) { "spree@example.com" }
      let!(:other_user_product_view_event) { create(:marketing_product_view_event, actor_id: other_user_type_id, actor_type: nil) }

      it "returns emails which do not include other user type emails" do
        expect(campaign_with_recepients.product_views_by).to_not include other_user_type_email
      end
    end

    context "when there are product views of targets other than Spree::Product" do
      let!(:other_type_product_view_event) { create(:marketing_product_view_event, target_type: nil, actor: user_with_cart_addition_event) }

      it "returns emails which do not include users which have view events of target other than Spree::Product" do
        expect(campaign_with_recepients.product_views_by).to_not include user_with_cart_addition_event
      end
    end

    context "when there are events of activity other than view" do
      let!(:other_activity_event) { create(:marketing_product_view_event, activity: "index", actor: user_with_cart_addition_event) }

      it "returns emails which do not include users which have view events of activity other than view" do
        expect(campaign_with_recepients.product_views_by).to_not include user_with_cart_addition_event.email
      end
    end

    context "when there are product view events of users other than contacts of that campaign" do
      let(:another_user) { create(:user) }
      let!(:another_user_product_view_event) { create(:marketing_product_view_event, actor: another_user) }

      it "returns emails which do not include user which are not contacts of this campaign" do
        expect(campaign_with_recepients.product_views_by).to_not include another_user.email
      end
    end
  end

  describe "#log_ins_by" do
    let!(:login_event) { create(:marketing_page_event, actor: user_with_login_event) }

    context "when there are product view events of users other than contacts of that campaign" do
      let(:another_user) { create(:user) }
      let!(:another_user_log_in_event) { create(:marketing_page_event, actor: another_user) }

      it "returns emails which do not include user which are not contacts of this campaign" do
        expect(campaign_with_recepients.log_ins_by).to_not include another_user.email
      end
    end

    context "when guest users views a page" do
      let!(:guest_user_log_in_view) { create(:marketing_page_event, actor: nil) }

      it "returns emails of users which are not guest users" do
        expect(campaign_with_recepients.log_ins_by.size).to eq 1
      end
    end

    context "when there are product view events before scheduled time" do
      let!(:old_log_in_view_event) { create(:marketing_page_event, actor: user_with_successful_purchase, created_at: timestamp) }

      it "returns emails which includes email of user_with_login_event" do
        expect(campaign_with_recepients.log_ins_by).to include user_with_login_event.email
      end
      it "returns emails which do not include email of user with old product view event" do
        expect(campaign_with_recepients.log_ins_by).to_not include user_with_successful_purchase.email
      end
    end

    context "when there are product view events of users other than Spree.user_class type" do
      let(:other_user_type_id) { 9 }
      let(:other_user_type_email) { "spree@example.com" }
      let!(:other_user_log_in_event) { create(:marketing_page_event, actor_id: other_user_type_id, actor_type: nil) }

      it "returns emails which do not include other user type emails" do
        expect(campaign_with_recepients.log_ins_by).to_not include other_user_type_email
      end
    end
  end

  describe "#cart_additions_by" do
    let(:user_with_cart_addition_event_order) { create(:order, user: user_with_cart_addition_event) }
    let!(:cart_addition_event) { create(:cart_addition_event, actor: user_with_cart_addition_event_order) }

    context "when there are cart events of activity other than add" do
      let(:user_with_login_event_order) { create(:order, user: user_with_login_event) }
      let!(:cart_event_other_than_add) { create(:cart_addition_event, activity: "empty_cart", actor: user_with_login_event_order) }

      it "returns emails which do not include users who have cart event of activity other than add" do
        expect(campaign_with_recepients.cart_additions_by).to_not include user_with_login_event.email
      end
    end

    context "when there are cart addition events before scheduled time" do
      let(:user_with_login_event_old_order) { create(:order, user: user_with_login_event) }
      let!(:old_cart_addition_event) { create(:cart_addition_event, created_at: timestamp, actor: user_with_login_event_old_order) }

      it "returns emails which include users with cart addition activity" do
        expect(campaign_with_recepients.cart_additions_by).to include user_with_cart_addition_event.email
      end
      it "returns emails which do not include users with cart activity before scheduled time" do
        expect(campaign_with_recepients.cart_additions_by).to_not include user_with_login_event.email
      end
    end

    context "when there are cart events of users other than contacts of the campaign" do
      let(:another_user) { create(:user) }
      let(:another_user_order) { create(:order, user: another_user) }
      let!(:another_user_cart_addition_event) { create(:cart_addition_event, actor: another_user_order) }

      it "returns emails which do not inlude users which are not conatcts of this campaign" do
        expect(campaign_with_recepients.cart_additions_by).to_not include another_user.email
      end
    end

    context "when guest users add an item to cart" do
      let(:guest_user_email) { "spree@example.com" }
      let(:guest_user_order) { create(:order, email: guest_user_email, user: nil) }
      let!(:guest_user_order_cart_addition_event) { create(:cart_addition_event, actor: guest_user_order) }

      it "returns emails of users which are not guest users" do
        expect(campaign_with_recepients.cart_additions_by).to_not include guest_user_email
      end
    end
  end

  describe "#purchases_by" do
    context "when the order is completed before scheduled time" do
      let!(:completed_order) { create(:completed_order_with_totals, user: user_with_successful_purchase) }
      let(:timestamp) { campaign_with_recepients.scheduled_at - 1.day }
      let(:user_with_old_completed_order) { create(:user) }
      let!(:old_completed_order) { create(:completed_order_with_custom_completion_time, completed_at: timestamp, user: user_with_product_view_event) }

      it "returns emails which include user_with_successful_purchase" do
        expect(campaign_with_recepients.purchases_by).to include user_with_successful_purchase.email
      end
      it "returns emails which do not include user with old completed order" do
        expect(campaign_with_recepients.purchases_by).to_not include user_with_product_view_event.email
      end
    end

    context "when there are guest users with completed orders" do
      let(:guest_user_email) { "spree@example.com" }
      let!(:guest_user_completed_order) { create(:completed_order_with_totals, email: guest_user_email, user: nil) }

      it "returns emails of users which are not guest users which have completed order" do
        expect(campaign_with_recepients.purchases_by).to_not include guest_user_email
      end
    end

    context "when there are completed order of users other than campaign contacts" do
      let(:another_user) { create(:user) }
      let!(:another_user_compeleted_orer) { create(:completed_order_with_totals, user: another_user) }

      it "returns emails which do not includes email of user which is not a contact of that campaign" do
        expect(campaign_with_recepients.purchases_by).to_not include another_user.email
      end
    end
  end

  describe "#user_ids" do
    it "includes all the user_ids of contacts of campaign" do
      expect(campaign_with_recepients.user_ids).to include *[user_with_successful_purchase.id, user_with_product_view_event.id, user_with_cart_addition_event.id, user_with_login_event.id]
    end
  end

  describe "#generate_reports" do
    let!(:first_login_event) { create(:marketing_page_event, actor: user_with_login_event) }
    let(:user_with_cart_addition_event_order) { create(:order, user: user_with_cart_addition_event) }
    let!(:cart_addition_event) { create(:cart_addition_event, actor: user_with_cart_addition_event_order) }
    let!(:first_completed_order) { create(:completed_order_with_totals, user: user_with_successful_purchase) }
    let!(:second_completed_order) { create(:completed_order_with_totals, user: user_with_cart_addition_event) }
    let!(:first_product_view_event) { create(:marketing_product_view_event, actor: user_with_product_view_event) }
    let!(:second_product_view_event) { create(:marketing_product_view_event, actor: user_with_cart_addition_event) }
    let(:reports_data) {
      {
        "log_ins" => {
          "emails" => [user_with_login_event.email, user_with_product_view_event.email, user_with_cart_addition_event.email].sort,
          "count" => 3
        },
        "cart_additions" => {
          "emails" => [user_with_cart_addition_event.email].sort,
          "count" => 1
        },
        "purchases" => {
          "emails" => [user_with_successful_purchase.email, user_with_cart_addition_event.email].sort,
          "count" => 2
        },
        "product_views" => {
          "emails" => [user_with_product_view_event.email, user_with_cart_addition_event.email].sort,
          "count" => 2
        },
        "emails_sent"=>200, "emails_bounced"=>2, "emails_opened"=>100, "emails_delivered"=>198
      }
    }
    let(:report_data) { { id: "42694e9e57",
                          emails_sent: 200,
                          bounces: {
                            hard_bounces: 0,
                            soft_bounces: 2,
                            syntax_errors: 0
                          },
                          forwards: {
                            forwards_count: 0,
                            forwards_opens: 0
                          },
                          opens: {
                            opens_total: 186,
                            unique_opens: 100,
                            open_rate: 42,
                            last_open: "2015-09-15T19:15:47+00:00"
                          } }.with_indifferent_access }
    let(:reports_data_in_json) { reports_data.to_json }

    before do
      campaign_with_recepients.update_stats(report_data)
      campaign_with_recepients.generate_reports
    end

    it "updates campaign stats with the reports data in json format" do
      expect(JSON.parse(campaign_with_recepients.stats).each { |k, v| v["emails"].sort! if v.is_a? Hash }).to eq reports_data
    end
  end

end
