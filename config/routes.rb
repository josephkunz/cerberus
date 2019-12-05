require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :cases, only: [ :index, :create, :show, :edit, :update, :destroy ] do
    resources :infringements, only: [ :create, :show, :destroy, :update ]
  end

  resources :snapshots, only: [ :show ]

  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/cases/:case_id/infringements/:id/refresh', to: 'infringements#refresh'
  get '/cases/:case_id/infringements/:id/sendzip', to: 'infringements#send_zip'
  get '/cases/:case_id/infringements/:id/createzip', to: 'infringements#create_zip'
  get '/cases/:case_id/infringements/:id/deletesnapshots', to: 'infringements#delete_snapshots'
  get '/snapshots/:id/nextsnapshot', to: 'snapshots#next_snapshot'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
