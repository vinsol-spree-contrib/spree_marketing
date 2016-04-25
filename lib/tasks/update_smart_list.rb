desc "update all the available smart lists"
namespace :smart_list do
  task update: :environment do |t, args|
    Spree::Marketing::List.update_all
  end
end
