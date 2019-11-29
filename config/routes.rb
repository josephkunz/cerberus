require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :cases, only: [ :index, :create, :show, :destroy ] do
    resources :infringements, only: [ :create, :show, :destroy ]
  end

  resources :snapshots, only: [ :show ]

  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
