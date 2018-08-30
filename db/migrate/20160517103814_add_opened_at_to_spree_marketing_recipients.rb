class AddOpenedAtToSpreeMarketingRecipients < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_marketing_recipients, :email_opened_at, :datetime, index: true
  end
end
