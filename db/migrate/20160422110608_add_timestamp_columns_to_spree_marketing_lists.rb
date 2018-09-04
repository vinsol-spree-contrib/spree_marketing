class AddTimestampColumnsToSpreeMarketingLists < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_marketing_lists, :created_at, :datetime, null: false, default: Time.current
    add_column :spree_marketing_lists, :updated_at, :datetime, null: false, default: Time.current
  end
end
