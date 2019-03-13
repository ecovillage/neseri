Rails.application.routes.draw do
  devise_for :users
  root 'seminars#index'
  resources :seminars, only: [:new, :create, :update, :index, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
