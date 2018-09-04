class CreateSpreeMarketingCampaigns < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_marketing_campaigns do |t|
      t.string :uid, null: false
      t.string :mailchimp_type, index: true
      t.string :name
      t.text :stats
      t.references :list, index: true
      t.datetime :scheduled_at
    end
  end
end
