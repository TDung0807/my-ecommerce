require 'swagger_helper'

RSpec.describe 'API::V1::Users::Passwords', type: :request do
  path '/api/v1/auth/forgot_password' do
    post('forgot password') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :email_params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string }
        },
        required: ['email']
      }

      response(200, 'password reset instructions sent successfully') do
        let!(:existing_user) { create(:user, email: "user@example.com", password: "password") }
        let(:email_params) { { email: "user@example.com" } }
        run_test!
      end

      response(400, 'email is missing') do
        let(:email_params) { {} }
        run_test!
      end
    end
  end

  path '/api/v1/auth/reset_password' do
    post('reset password') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :reset_params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: %w[email password password_confirmation]
      }

      response(200, 'password reset successfully') do
        let!(:existing_user) { create(:user, email: "user@example.com", password: "oldpass") }
        let(:reset_params) { { email: "user@example.com", password: "newpass", password_confirmation: "newpass" } }
        run_test!
      end

      response(422, 'user not found') do
        let(:reset_params) { { email: "missing@example.com", password: "newpass", password_confirmation: "newpass" } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/change_password' do
    post('change password') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              current_password: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[current_password password password_confirmation]
          }
        },
        required: ['user']
      }

      response(200, 'password updated successfully') do
        let!(:existing_user) { create(:user, email: "user@example.com", password: "oldpass") }
        let(:Authorization) do
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(existing_user, :user, nil)
          "Bearer #{token}"
        end
        let(:user) { { user: { current_password: "oldpass", password: "newpass", password_confirmation: "newpass" } } }
        run_test!
      end

      response(422, 'incorrect current password') do
        let!(:existing_user) { create(:user, email: "user@example.com", password: "oldpass") }
        let(:Authorization) do
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(existing_user, :user, nil)
          "Bearer #{token}"
        end
        let(:user) { { user: { current_password: "wrongpass", password: "newpass", password_confirmation: "newpass" } } }
        run_test!
      end
    end
  end
end
