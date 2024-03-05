Rails.application.routes.draw do
  get 'product_alternatives/index'
  get 'product_alternatives/show'
  get 'shop_alternatives/index'
  get 'shop_alternatives/show'
  get 'histories/index'
  get 'histories/show'
  get 'histories/destroy'
  get 'products/index'
  get 'products/show'
  get 'shops/index'
  get 'shops/show'
  get 'users/index'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
