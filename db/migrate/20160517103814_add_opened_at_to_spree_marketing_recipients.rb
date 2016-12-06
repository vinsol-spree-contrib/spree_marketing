class AddOpenedAtToSpreeMarketingRecipients < ActiveRecord::Migration
  def change
    add_column :spree_marketing_recipients, :email_opened_at, :datetime, index: true
  end
end
