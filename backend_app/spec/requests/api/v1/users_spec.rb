require 'rails_helper'

RSpec.describe "API::V1::Users", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { auth_headers_for(current_user) }

  before { $redis.flushdb }

  describe "GET /api/v1/users" do
    it "returns all users and caches them" do
      create_list(:user, 2)

      get "/api/v1/users", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 2
      expect($redis.get("users:all")).not_to be_nil
    end

    it "returns cached users if present" do
      users = create_list(:user, 2)
      $redis.set("users:all", users.to_json)

      get "/api/v1/users", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end
  end

  describe "GET /api/v1/users/:id" do
    it "returns a user" do
      user = create(:user)

      get "/api/v1/users/#{user.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(user.id)
    end
  end

  describe "PUT /api/v1/users/:id" do
    it "updates a user with name and phone, invalidates cache" do
      user = create(:user)

      put "/api/v1/users/#{user.id}",
        params: {
          user: {
            email: "updated@example.com",
            name: "Updated Name",
            phone_number: "0987654321"
          }
        }.to_json,
        headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["email"]).to eq("updated@example.com")
      expect(json["name"]).to eq("Updated Name")
      expect(json["phone_number"]).to eq("0987654321")
      expect($redis.get("users:all")).to be_nil
    end

    it "returns errors for invalid update" do
      user = create(:user)

      put "/api/v1/users/#{user.id}",
          params: { user: { email: "" } }.to_json,
          headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/users/:id" do
    it "deletes a user and invalidates cache" do
      user = create(:user)

      delete "/api/v1/users/#{user.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(User.find_by(id: user.id)).to be_nil
      expect($redis.get("users:all")).to be_nil
    end
  end
end
