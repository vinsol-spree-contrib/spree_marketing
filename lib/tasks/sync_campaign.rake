desc "sync all campaigns for smart lists"
namespace :smart_list do
  namespace :campaign do
    task sync: :environment do |t, args|
      Spree::Marketing::Campaign.sync
    end
  end
end
