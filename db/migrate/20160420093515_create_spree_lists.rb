class CreateSpreeLists < ActiveRecord::Migration
  def change
    create_table :spree_lists do |t|
      t.string :uid, null: false
      t.string :name, index: true
      t.boolean :active, default: true, null: false
      t.index [:active, :name]
    end
  end
end
