class CreateSpreeContacts < ActiveRecord::Migration
  def change
    create_table :spree_marketing_contacts do |t|
      t.string :mailchimp_id
      t.string :uid, null: false
      t.string :email, null: false, index: true
      t.boolean :active, default: true, null: false
      t.index [:active, :email]
    end
  end
end
