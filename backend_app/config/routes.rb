require 'sidekiq/web'
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq' 
  namespace :api do
    namespace :v1 do
      scope module: :users, path: 'users' do
        devise_for :users,
          path: '',
          path_names: {
            sign_in: 'login',
            sign_out: 'logout',
            registration: 'signup'
          },
          controllers: {
            sessions: 'api/v1/users/sessions',
            registrations: 'api/v1/users/registrations'
          }
      end
    end
  end
end
