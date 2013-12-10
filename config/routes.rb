AWSSnapshots::Application.routes.draw do

  root 'dashboard#index'

  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords"}

end
