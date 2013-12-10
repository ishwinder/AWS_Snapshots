AWSSnapshots::Application.routes.draw do

  root 'dashboard#index'

  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords"}
  devise_scope :user do
   get "logout", to: "devise/sessions#destroy", as: "logout"
 end

  resources :users, only: [:add_aws_creds, :update_aws_creds] do
    get :add_aws_creds, on: :member
    patch :update_aws_creds, on: :member
  end
end
