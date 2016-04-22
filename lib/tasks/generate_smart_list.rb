desc "generate all the available smart lists"
namespace :smart_list do
  task generate: :environment do |t, args|
    Spree::Marketing::List.generate
  end
end
