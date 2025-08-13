require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      devise_for :users,
                 path: 'users',
                 path_names: {
                   sign_in: 'login',
                   sign_out: 'logout',
                   registration: 'signup'
                 },
                 controllers: {
                   sessions: 'api/v1/users/sessions',
                   registrations: 'api/v1/users/registrations'
                 }

      devise_scope :user do
        post 'users/forgot_password', to: 'users/passwords#forgot'
        post 'users/reset_password',  to: 'users/passwords#reset'
        post 'users/change_password', to: 'users/passwords#update'
      end

      resources :users
    end
  end
end
