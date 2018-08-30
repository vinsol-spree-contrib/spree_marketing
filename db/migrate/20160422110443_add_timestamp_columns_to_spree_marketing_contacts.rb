class AddTimestampColumnsToSpreeMarketingContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_marketing_contacts, :created_at, :datetime, null: false, default: Time.current
    add_column :spree_marketing_contacts, :updated_at, :datetime, null: false, default: Time.current
  end
end
