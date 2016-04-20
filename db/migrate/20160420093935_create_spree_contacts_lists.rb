class CreateSpreeContactsLists < ActiveRecord::Migration
  def change
    create_table :spree_contacts_lists do |t|
      t.references :contacts, index: true
      t.references :lists, index: true
      t.index [:list_id, :contact_id]
      t.boolean :active, default: true, index: true
    end
  end
end
