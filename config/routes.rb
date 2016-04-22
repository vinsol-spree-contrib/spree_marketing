Spree::Core::Engine.routes.draw do

  namespace :admin do
    resources :lists
  end

end
