Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :cases, only: [ :index, :create, :show ] do
    resources :infringements, only: [ :create, :show ]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end