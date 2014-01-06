AWSSnapshots::Application.routes.draw do

  root 'dashboard#index'

  resources :dashboard do
    get :load_instances_summary, on: :collection
  end

  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords"}
  devise_scope :user do
   get "logout", to: "devise/sessions#destroy", as: "logout"
 end

  resources :users, only: [:add_aws_creds, :update_aws_creds, :update_password] do
    get :add_aws_creds, on: :member
    patch :update_aws_creds, on: :member
    patch :update_password, on: :member
  end

    get 'profile', to: 'users#show'
    get 'change_password', to: 'users#change_password'
    get "edit_aws_creds", to: "users#edit_aws_creds", as: "edit_aws_creds" 
    get 'change_default_region', to: 'users#change_default_region'

  resources :aws_actions do
    get :load_instances, on: :collection
    get :load_snapshots, on: :collection
    get :load_volumes, on: :collection
    get :create_snapshot, on: :collection
    get :create_instant_snapshot, on: :collection
    get :delete_snapshot, on: :collection
    get :load_volumes_for_instance, on: :collection
    get :create_schedule, on: :collection
    get :wizard_filtered_instances, on: :collection
  end

  resources :elements do
    get :instances, on: :collection
    get :volumes, on: :collection
    get :snapshots, on: :collection
  end

  resources :scheduled_snapshots
end
