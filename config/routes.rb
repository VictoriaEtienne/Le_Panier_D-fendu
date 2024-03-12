Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  post '/update_location', to: 'pages#update_location'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :histories, except: [:edit, :update] do
    resources :shops, only: [:index, :show] do
      member do
        get :itinerary
      end
    end
  end

  resources :product_alternatives, only: :show do
    collection do
      get :search
    end
    resources :shops, only: :index
  end

  # TODO: a remplacer quand le resources shops nesté dans histories sera correctement connecté
  resources :shops, only: [:index, :show]

  # get "dashboard", to: "pages#dashboard", as: :dashboard
  get "score", to: "pages#score"
  # resources
  # Defines the root path route ("/")
  # root "posts#index"
end
