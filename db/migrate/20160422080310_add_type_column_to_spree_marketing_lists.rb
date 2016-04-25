class AddTypeColumnToSpreeMarketingLists < ActiveRecord::Migration
  def change
    add_column :spree_marketing_lists, :type, :string, index: true
  end
end
