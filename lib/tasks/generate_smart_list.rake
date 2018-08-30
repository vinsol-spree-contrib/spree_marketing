desc 'generate all the available smart lists'
namespace :spree_marketing do
  namespace :smart_list do
    task generate: :environment do |_t, _args|
      Spree::Marketing::List.generate_all
    end
  end
end
