class CreateSpreeLists < ActiveRecord::Migration
  def change
    create_table :spree_lists do |t|
      t.string :uid, null: false
      t.string :name
      t.boolean :active, default: true, index: true
    end
  end
end
