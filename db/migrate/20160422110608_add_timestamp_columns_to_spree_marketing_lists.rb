class AddTimestampColumnsToSpreeMarketingLists < ActiveRecord::Migration
  def change
    change_table :spree_marketing_lists do |t|
      t.timestamps
    end
  end
end
