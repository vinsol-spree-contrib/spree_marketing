Spree::Core::Engine.routes.draw do

  namespace :admin do
    namespace :marketing do
      resources :lists
      resources :campaigns
    end
  end

end
