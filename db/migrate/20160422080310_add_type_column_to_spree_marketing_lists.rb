class AddTypeColumnToSpreeMarketingLists < ActiveRecord::Migration
  def change
    add_column :spree_marketing_lists, :type, :string, null: false, index: true
  end
end
