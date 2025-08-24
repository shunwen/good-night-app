Rails.application.routes.draw do
  resources :follows

  namespace :users do
    resources :sleeps
    post :followings, to: "followings#create"
    delete :followings, to: "followings#destroy"
    
    namespace :following_others do
      resources :prev_week_sleeps, only: [:index]
    end
  end
  resources :users
  
  get 'api_test', to: 'api_test#index'
  post 'api_test/impersonate', to: 'api_test#impersonate'
  delete 'api_test/clear_auth', to: 'api_test#clear_auth'
  post 'api_test/create_test_data', to: 'api_test#create_test_data'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
