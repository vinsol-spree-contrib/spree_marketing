Spree::Core::Engine.routes.draw do

  namespace :admin do
    namespace :marketing do
      resources :lists
    end
  end

end
