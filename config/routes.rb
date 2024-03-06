Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  post '/update_location', to: 'pages#update_location'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :histories, except: [:edit, :update]

  resources :product_alternatives, only: :show do
    resources :shops, only: :index
  end

  resources :shops, only: [:show] do
    get :all_shops, on: :collection, as: :all
  end

  get "home_new", to: "pages#home_new"

  # resources
  # Defines the root path route ("/")
  # root "posts#index"
end
