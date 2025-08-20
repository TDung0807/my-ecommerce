# config/routes.rb
require 'sidekiq/web'

Rails.application.routes.draw do
  # Dev tools
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq' 

  namespace :api do
    namespace :v1 do
      devise_for :users,
                 path: 'auth',
                 path_names: {
                   sign_in:  'login',
                   sign_out: 'logout',
                   sign_up:  'signup'    # <-- correct key
                 },
                 controllers: {
                   sessions:      'api/v1/users/sessions',
                   registrations: 'api/v1/users/registrations'
                 }

      devise_scope :user do
        post 'auth/forgot_password', to: 'users/passwords#forgot'
        post 'auth/reset_password',  to: 'users/passwords#reset'
        post 'auth/change_password', to: 'users/passwords#update'
      end

      resources :users, only: [:index, :show, :update, :destroy] do
        resources :user_addresses, only: [:index, :create], shallow: true do
          collection { get :default }           # /users/:user_id/user_addresses/default
          member     { patch :make_default }    # /user_addresses/:id/make_default
        end
      end

      resources :addresses, only: [:index, :show, :create]
    end
  end
end
