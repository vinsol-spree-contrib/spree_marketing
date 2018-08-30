class CreateSpreeMarketingRecipients < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_marketing_recipients do |t|
      t.references :campaign, index: true
      t.references :contact, index: true
    end
  end
end
