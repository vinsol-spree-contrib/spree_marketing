Spree::Core::Engine.routes.draw do

  namespace :admin do
    namespace :marketing do
      resources :lists, only: [:show, :index]
      resources :campaigns, only: [:show, :index]
    end
  end

end
