class CreateSpreeContactsLists < ActiveRecord::Migration
  def change
    create_table :spree_contacts_lists do |t|
      t.references :contact, index: true
      t.references :list, index: true
      t.index [:list_id, :contact_id]
      t.boolean :active, default: true, index: true, null: false
    end
  end
end
