require 'swagger_helper'

RSpec.describe 'API::V1::Users:Sessions', type: :request do
    path '/api/v1/users/login' do
        post("user login") do
            tags 'Authentication'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :user, in: :body, schema:{
                type: :object,
                properties: {
                    user: {
                        type: :object,
                        properties: {
                            email: {type: :string},
                            password: {type: :string}
                        },
                        required: %w[email password]
                    }
                },
                required: ['user']
            }
            response(200, 'login successfully') do
                let!(:existing_user) { create(:user, email: "user@example.com", password: "password") }
                let(:user) {{user: {email:"user@example.com", password:"password"}}}
                run_test!
            end

            response(401,'incorrect email or password') do
                let(:user){{user:{email:"user@example.com",password:"passwordsaine"}}}
                run_test!
            end
        end
    end
end