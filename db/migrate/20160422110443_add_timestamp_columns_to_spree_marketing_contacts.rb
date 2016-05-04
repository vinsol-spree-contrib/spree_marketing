class AddTimestampColumnsToSpreeMarketingContacts < ActiveRecord::Migration
  def change
    change_table :spree_marketing_contacts do |t|
      t.timestamps
    end
  end
end
