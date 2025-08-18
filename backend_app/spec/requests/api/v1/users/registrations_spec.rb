require 'swagger_helper'

RSpec.describe 'API::V1::Users::Registrations', type: :request do
  path '/api/v1/users/signup' do
    post('user signup') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[email password password_confirmation]
          }
        },
        required: ['user']
      }

      response(200, 'signed up successfully') do
        let(:user) { { user: { email: 'user@example.com', password: 'password', password_confirmation: 'password' } } }
        run_test!
      end

      # response(422, 'invalid input') do
      #   let(:user) { { user: { email: '', password: '', password_confirmation: '' } } }
      #   run_test!
      # end
    end
  end
end
