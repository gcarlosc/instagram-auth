Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#prueba'
  get '/auth/failure', to: 'sessions#failure'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  resources :sessions do
    get '/media', to: 'sessions#media',on: :collection
    get '/user', to: 'sessions#user',on: :collection
  end
  root to: "sessions#new"

  get '/instagram/callback', to: 'instagram#callback'
  get '/instagram/connect', to: 'instagram#connect'
end
