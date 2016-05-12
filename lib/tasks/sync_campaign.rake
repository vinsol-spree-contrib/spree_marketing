desc "sync all campaigns for smart lists"
namespace :spree_marketing do
  namespace :smart_list do
    namespace :campaign do
      task sync: :environment do |t, args|
        Spree::Marketing::Campaign.sync
      end
    end
  end
end
