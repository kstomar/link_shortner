# frozen_string_literal: true

Rails.application.routes.draw do
  resources :shortened_urls
  get '/:short_url', to: 'shortened_urls#redirect_to_main_url', as: 'short_url'

  resources :users, param: :_username
  post '/login', to: 'users#login'
end
