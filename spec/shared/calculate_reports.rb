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

  describe "#product_views" do
    let!(:product_view_event) { create(:marketing_product_view_event, actor: user_with_product_view_event) }

    context "when there are product views of guest users" do
      let!(:guest_user_product_view) { create(:marketing_product_view_event, actor: nil) }

      it "returns emails which do not include nil" do
        expect(campaign_with_recepients.product_views).to_not include nil
      end
    end

    context "when there are product view events before scheduled time" do
      let!(:old_product_view_event) { create(:marketing_product_view_event, actor: user_with_successful_purchase, created_at: timestamp) }

      it "returns emails which includes email of user_with_product_view_event" do
        expect(campaign_with_recepients.product_views).to include user_with_product_view_event.email
      end
      it "returns emails which do not include email of user woth old product view event" do
        expect(campaign_with_recepients.product_views).to_not include user_with_successful_purchase.email
      end
    end

    context "when there are product view events of users other than Spree.user_class type" do
      let(:other_user_type_id) { 9 }
      let(:other_user_type_email) { "spree@example.com" }
      let!(:other_user_product_view_event) { create(:marketing_product_view_event, actor_id: other_user_type_id, actor_type: nil) }

      it "returns emails which do not include other user type emails" do
        expect(campaign_with_recepients.product_views).to_not include other_user_type_email
      end
    end

    context "when there are product views of targets other than Spree::Product" do
      let!(:other_type_product_view_event) { create(:marketing_product_view_event, target_type: nil, actor: user_with_cart_addition_event) }

      it "returns emails which do not include users which have view events of target other than Spree::Product" do
        expect(campaign_with_recepients.product_views).to_not include user_with_cart_addition_event
      end
    end

    context "when there are events of activity other than view" do
      let!(:other_activity_event) { create(:marketing_product_view_event, activity: "index", actor: user_with_cart_addition_event) }

      it "returns emails which do not include users which have view events of activity other than view" do
        expect(campaign_with_recepients.product_views).to_not include user_with_cart_addition_event.email
      end
    end

    context "when there are product view events of users other than contacts of that campaign" do
      let(:another_user) { create(:user) }
      let!(:another_user_product_view_event) { create(:marketing_product_view_event, actor: another_user) }

      it "returns emails which do not include user which are not contacts of this campaign" do
        expect(campaign_with_recepients.product_views).to_not include another_user.email
      end
    end
  end

  describe "#log_ins" do
    let!(:login_event) { create(:marketing_page_event, actor: user_with_login_event) }

    context "when there are product view events of users other than contacts of that campaign" do
      let(:another_user) { create(:user) }
      let!(:another_user_product_view_event) { create(:marketing_page_event, actor: another_user) }

      it "returns emails which do not include user which are not contacts of this campaign" do
        expect(campaign_with_recepients.log_ins).to_not include another_user.email
      end
    end

    context "when there are product views of guest users" do
      let!(:guest_user_product_view) { create(:marketing_page_event, actor: nil) }

      it "returns emails which do not include nil" do
        expect(campaign_with_recepients.log_ins).to_not include nil
      end
    end

    context "when there are product view events before scheduled time" do
      let!(:old_product_view_event) { create(:marketing_page_event, actor: user_with_successful_purchase, created_at: timestamp) }

      it "returns emails which includes email of user_with_login_event" do
        expect(campaign_with_recepients.log_ins).to include user_with_login_event.email
      end
      it "returns emails which do not include email of user woth old product view event" do
        expect(campaign_with_recepients.log_ins).to_not include user_with_successful_purchase.email
      end
    end

    context "when there are product view events of users other than Spree.user_class type" do
      let(:other_user_type_id) { 9 }
      let(:other_user_type_email) { "spree@example.com" }
      let!(:other_user_product_view_event) { create(:marketing_page_event, actor_id: other_user_type_id, actor_type: nil) }

      it "returns emails which do not include other user type emails" do
        expect(campaign_with_recepients.log_ins).to_not include other_user_type_email
      end
    end
  end

  describe "#cart_additions" do
    let(:user_with_cart_addition_event_order) { create(:order, user: user_with_cart_addition_event) }
    let!(:cart_addition_event) { create(:cart_addition_event, actor: user_with_cart_addition_event_order) }

    context "when there are cart events of activity other than add" do
      let(:user_with_login_event_order) { create(:order, user: user_with_login_event) }
      let!(:cart_event_other_than_add) { create(:cart_addition_event, activity: "empty_cart", actor: user_with_login_event_order) }

      it "returns emails which do not include users who have cart event of activity other than add" do
        expect(campaign_with_recepients.cart_additions).to_not include user_with_login_event.email
      end
    end

    context "when there are cart addition events before scheduled time" do
      let(:user_with_login_event_old_order) { create(:order, user: user_with_login_event) }
      let!(:old_cart_addition_event) { create(:cart_addition_event, created_at: timestamp, actor: user_with_login_event_old_order) }

      it "returns emails which include users with cart addition activity" do
        expect(campaign_with_recepients.cart_additions).to include user_with_cart_addition_event.email
      end
      it "returns emails which do not include users with cart activity before scheduled time" do
        expect(campaign_with_recepients.cart_additions).to_not include user_with_login_event.email
      end
    end

    context "when there are cart events of users other than contacts of the campaign" do
      let(:another_user) { create(:user) }
      let(:another_user_order) { create(:order, user: another_user) }
      let!(:another_user_cart_addition_event) { create(:cart_addition_event, actor: another_user_order) }

      it "returns emails which do not inlude users which are not conatcts of this campaign" do
        expect(campaign_with_recepients.cart_additions).to_not include another_user.email
      end
    end
  end

  describe "#purchases" do
    let!(:completed_order) { create(:completed_order_with_totals, user: user_with_successful_purchase) }

    context "when the order is completed before scheduled time" do
      let(:timestamp) { campaign_with_recepients.scheduled_at - 1.day }
      let(:user_with_old_completed_order) { create(:user) }
      let!(:old_completed_order) { create(:completed_order_with_custom_completion_time, completed_at: timestamp, user: user_with_product_view_event) }

      it "returns emails which include user_with_successful_purchase" do
        expect(campaign_with_recepients.purchases).to include user_with_successful_purchase.email
      end
      it "returns emails which do not include user woth old completed order" do
        expect(campaign_with_recepients.purchases).to_not include user_with_product_view_event.email
      end
    end

    context "when there are guest users with completed orders" do
      let(:guest_user_email) { "spree@example.com" }
      let!(:guest_user_completed_order) { create(:completed_order_with_totals, email: guest_user_email, user: nil) }

      it "returns emails which do not include guest user email which have completed order" do
        expect(campaign_with_recepients.purchases).to_not include guest_user_email
      end
    end

    context "when there are completed order of users other than campaign contacts" do
      let(:another_user) { create(:user) }
      let!(:another_user_compeleted_orer) { create(:completed_order_with_totals, user: another_user) }

      it "returns emails which do not includes email of user which is not a contact of that campaign" do
        expect(campaign_with_recepients.purchases).to_not include another_user.email
      end
    end
  end

  describe "#contact_ids" do
    it "includes all the user_ids of contacts of campaign" do
      expect(campaign_with_recepients.contact_ids).to include *[user_with_successful_purchase.id, user_with_product_view_event.id, user_with_cart_addition_event.id, user_with_login_event.id]
    end
  end

  describe "#make_reports" do
    let!(:first_login_event) { create(:marketing_page_event, actor: user_with_login_event) }
    let!(:second_login_event) { create(:marketing_page_event, actor: user_with_product_view_event) }
    let!(:third_login_event) { create(:marketing_page_event, actor: user_with_cart_addition_event) }
    let(:user_with_cart_addition_event_order) { create(:order, user: user_with_cart_addition_event) }
    let!(:cart_addition_event) { create(:cart_addition_event, actor: user_with_cart_addition_event_order) }
    let!(:first_completed_order) { create(:completed_order_with_totals, user: user_with_successful_purchase) }
    let!(:second_completed_order) { create(:completed_order_with_totals, user: user_with_cart_addition_event) }
    let!(:first_product_view_event) { create(:marketing_product_view_event, actor: user_with_product_view_event) }
    let!(:second_product_view_event) { create(:marketing_product_view_event, actor: user_with_cart_addition_event) }
    let(:reports_data) {
      {
        "log_ins" => {
          "emails" => [user_with_login_event.email, user_with_product_view_event.email, user_with_cart_addition_event.email],
          "count" => 3
        },
        "cart_additions" => {
          "emails" => [user_with_cart_addition_event.email],
          "count" => 1
        },
        "purchases" => {
          "emails" => [user_with_successful_purchase.email, user_with_cart_addition_event.email],
          "count" => 2
        },
        "product_views" => {
          "emails" => [user_with_product_view_event.email, user_with_cart_addition_event.email],
          "count" => 2
        },
        "emails_sent" => campaign_with_recepients.contacts.count
      }
    }
    let(:reports_data_in_json_format) { reports_data.to_json }

    before { campaign_with_recepients.make_reports }

    it "updates campaign stats with the reports data in json format" do
      expect(campaign_with_recepients.stats).to eq reports_data_in_json_format
    end
  end

end
