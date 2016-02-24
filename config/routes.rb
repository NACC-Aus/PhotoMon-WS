NaccWs::Application.routes.draw do
  get "page/index"

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  resources :sessions, only: [:create]
  resources :photos, only: [:create, :update, :index]
  resources :sites, only: [:index]
  resources :projects, only: [:index]
  root to: redirect('/admin')

  get '/gallery' => 'gallery#index'
  get '/gallery/get_project_sites' => 'gallery#get_project_sites'
  get '/gallery/:site' => 'gallery#show', as: "gallery_side"
end
