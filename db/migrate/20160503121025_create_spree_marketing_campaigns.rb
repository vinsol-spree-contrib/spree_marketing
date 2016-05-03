class CreateSpreeMarketingCampaigns < ActiveRecord::Migration
  def change
    create_table :spree_marketing_campaigns do |t|
      t.string :uid, null: false
      t.string :mailchimp_type, index: true
      t.string :name
      t.references :list, index: true
      t.datetime :scheduled_at
    end
  end
end
