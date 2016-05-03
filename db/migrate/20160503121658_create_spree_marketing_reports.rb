class CreateSpreeMarketingReports < ActiveRecord::Migration
  def change
    create_table :spree_marketing_reports do |t|
      t.references :campaign, index: true
      t.text :data
      t.integer :report_index, index: true
      t.integer :total_value, default: 0
    end
  end
end
