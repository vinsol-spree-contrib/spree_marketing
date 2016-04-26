class AddTimestampColumnsToSpreeMarketingContactsLists < ActiveRecord::Migration
  def change
    change_table :spree_marketing_contacts_lists do |t|
      t.timestamps #null: false
    end
  end
end
