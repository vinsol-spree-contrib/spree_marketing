class AddUserToSpreeMarketingContacts < ActiveRecord::Migration[5.0]
  def change
    add_reference :spree_marketing_contacts, :user
  end
end
