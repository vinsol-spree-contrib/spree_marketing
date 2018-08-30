class CreateSpreeLists < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_marketing_lists do |t|
      t.string :uid, null: false
      t.string :name, index: true
      t.boolean :active, default: true, null: false
      t.index %i[active name]
    end
  end
end
