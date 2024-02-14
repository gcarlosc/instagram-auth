Rails.application.routes.draw do
  root to: "sessions#new"

  resources :sessions do
    get '/callback', to: 'sessions#callback',on: :collection
    get '/media', to: 'sessions#media',on: :collection
    get '/user', to: 'sessions#user',on: :collection
  end

  get '/instagram/callback', to: 'instagram#callback'
  post '/instagram/access', to: 'instagram#access'
  get '/instagram', to: 'instagram#index'
  get '/instagram/user_info', to: 'instagram#user_info'
  get '/instagram/user_insights', to: 'instagram#user_insights'
  get '/instagram/media_insights', to: 'instagram#media_insights'

  resources :tiktok, only: [:index] do
    get :research_token, on: :collection
    get :research_api, on: :collection
  end
  get '/auth/tiktok/login', to: 'tiktok#tiktok_auth'
  get '/auth/callback', to: 'tiktok#callback'


  resources :subscriptions, only: [:index, :create] do
    post :create_payment, on: :collection
    get :new_card, on: :collection
    post :create_card, on: :collection
    get :remove_cards, on: :collection
    get :list_payments, on: :collection
  end

  namespace :payment_gateway, path: 'pg' do
    resources :payment, only: [:create] do
      post :create_sub, on: :collection
    end
  end

  resources :culqi, only: [:index, :create]
end
