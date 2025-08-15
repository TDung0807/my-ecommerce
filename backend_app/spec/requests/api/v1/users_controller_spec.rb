# spec/requests/api/v1/users_controller_spec.rb
require 'swagger_helper'

RSpec.describe 'API::V1::Users', type: :request do

  let!(:user) { create(:user) }

  path '/api/v1/users' do
    get('list users') do
      tags 'Users'
      produces 'application/json'

      response(200, 'successful') do
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json).to be_an(Array)
          expect(json.first['email']).to eq(user.email)
        end
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'user id'

    get('show user') do
      tags 'Users'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { user.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['email']).to eq(user.email)
        end
      end

      response(404, 'not found') do
        let(:id) { '999999' }
        run_test!
      end
    end
  end
end
