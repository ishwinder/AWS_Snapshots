AWSSnapshots::Application.routes.draw do

  root 'dashboard#index'

  devise_for :users, controllers: {sessions: "sessions", registrations: "registrations", passwords: "passwords"}

end
