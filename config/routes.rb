Rails.application.routes.draw do
  devise_for :users
  root 'seminars#index'

  get 'impressum', to: 'pages#impressum'
  get 'privacy',   to: 'pages#privacy'
  get 'contact',   to: 'pages#contact'
  get 'about',     to: 'pages#about'

  resources :seminars
  namespace :admin do
    resources :emails, only: [:index, :show]
  end

  resource :instructor, only: [:show, :edit, :update]
  resolve('Instructor') { :instructor }

  resource :contact_message, only: [:show, :create, :new]
  resolve('contact') { :contact_message }

  resources :rooms
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
