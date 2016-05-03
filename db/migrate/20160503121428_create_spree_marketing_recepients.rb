class CreateSpreeMarketingRecepients < ActiveRecord::Migration
  def change
    create_table :spree_marketing_recepients do |t|
      t.references :campaign, index: true
      t.references :contact, index: true
    end
  end
end
