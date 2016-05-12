Spree::Core::Engine.routes.draw do

  namespace :admin do
    namespace :marketing do
      resources :lists, only: [:show, :index]
      resources :campaigns, only: [:show, :index] do
        member do
          get :display_recipient_emails
        end
      end
      post 'campaigns/sync', to: 'campaigns#sync'
    end
  end

end
