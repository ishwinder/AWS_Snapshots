AWSSnapshots::Application.routes.draw do

  root 'dashboard#index'

  resources :dashboard do
    get :load_instances_summary, on: :collection
  end

  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords"}
  devise_scope :user do
   get "logout", to: "devise/sessions#destroy", as: "logout"
 end

  resources :users, only: [:add_aws_creds, :update_aws_creds] do
    get :add_aws_creds, on: :member
    patch :update_aws_creds, on: :member
  end

  resources :aws_actions do
    get :load_instances, on: :collection
    get :load_snapshots, on: :collection
    get :load_volumes, on: :collection
    get :create_snapshot, on: :collection
    get :create_instant_snapshot, on: :collection
    get :delete_snapshot, on: :collection
  end

  resources :elements do
    get :instances, on: :collection
    get :volumes, on: :collection
    get :snapshots, on: :collection
  end

  resources :scheduled_snapshots
end
