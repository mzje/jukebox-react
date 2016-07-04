Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root to: "base#index", as: :home

  get "/lastfm/authenticate" => "last_fm#authenticate", as: :lastfm
  get "/auth/spotify/callback", to: "users#spotify"
  post "/lastfm/authenticate" => "last_fm#authenticate"

  get "/favourites" => "favourites#index", as: :favourites
  get "/search" => "search#index", as: :search
  get "/random" => "base#random", as: :random
  get "/statistics/track_info" => "statistics#track_info"
  get "/logout" => "sessions#destroy", as: :logout
  get "/login" => "sessions#new", as: :login
  get "/register" => "users#create", as: :register
  get "/signup" => "users#new", as: :signup

  resources :music_updates, path_prefix: 'admin'
  resources :artworks, only: [:show], requirements: { id: /.+/ }
  resources :downloads
  resources :users
  resource :session

  namespace :api do
    namespace :v1 do
      get 'status.json', to: GetStatusController.action(:get_status)
    end
  end
end
