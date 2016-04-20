class CreateSpreeContacts < ActiveRecord::Migration
  def change
    create_table :spree_contacts do |t|
      t.string :mailchimp_id
      t.string :uid, null: false
      t.string :email, null: false
      t.boolean :active, default: true, index: true
    end
  end
end
