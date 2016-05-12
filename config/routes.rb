Spree::Core::Engine.routes.draw do

  namespace :admin do
    namespace :marketing do
      resources :lists, only: [:show, :index]
      resources :campaigns, only: [:show, :index]
      post 'campaigns/sync', to: 'campaigns#sync'
      get 'campaigns/display_recipient_emails', to: 'campaigns#display_recipient_emails'
    end
  end

end
