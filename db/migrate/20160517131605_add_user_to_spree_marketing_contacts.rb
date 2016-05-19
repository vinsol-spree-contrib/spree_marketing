class AddUserToSpreeMarketingContacts < ActiveRecord::Migration
  def change
    add_reference :spree_marketing_contacts, :user
  end
end
