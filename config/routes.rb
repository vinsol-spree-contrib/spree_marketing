Spree::Core::Engine.routes.draw do
  namespace :admin do
    namespace :marketing do
      resources :lists, only: %i[show index]
      resources :campaigns, only: %i[show index] do
        member do
          get :display_recipient_emails
        end
      end
      post 'campaigns/sync', to: 'campaigns#sync'
    end
  end
end
