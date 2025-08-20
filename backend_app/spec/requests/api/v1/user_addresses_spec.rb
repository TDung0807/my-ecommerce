require 'rails_helper'

RSpec.describe "API::V1::UserAddresses", type: :request do
  let(:user) { create(:user) }
  let(:headers) do
    auth_headers_for(user).merge(
      "CONTENT_TYPE" => "application/json",
      "ACCEPT"       => "application/json"
    )
  end

  before { $redis.flushdb }

  describe "GET /api/v1/users/:user_id/user_addresses" do
    it "returns all addresses for a user" do
      addr1 = create(:address)
      addr2 = create(:address)
      create(:user_address, user: user, address: addr1)
      create(:user_address, user: user, address: addr2)

      get "/api/v1/users/#{user.id}/user_addresses", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.first).to have_key("address")
    end
  end

  describe "POST /api/v1/users/:user_id/user_addresses" do
    it "creates a new user_address with nested address" do
      post "/api/v1/users/#{user.id}/user_addresses",
        params: {
          user_address: {
            is_default: true,
            address_attributes: {
              unit_number: "12A",
              street_number: "77",
              address_line: "Pham Ngoc Thach",
              region: "Ba Dinh",
              city_id: 1,
              country_id: 1
            }
          }
        }.to_json,
        headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["is_default"]).to eq(true)
      expect(json["address"]["address_line"]).to eq("Pham Ngoc Thach")
      expect($redis.get("user:#{user.id}:addresses")).not_to be_nil
    end

    it "returns validation errors for invalid input" do
      post "/api/v1/users/#{user.id}/user_addresses",
        params: { user_address: { is_default: true } }.to_json,
        headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).not_to be_empty
    end
  end

  describe "GET /api/v1/user_addresses/:id" do
    it "shows a specific user_address" do
      ua = create(:user_address, user: user, address: create(:address))

      get "/api/v1/user_addresses/#{ua.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(ua.id)
      expect(json["address"]["id"]).to eq(ua.address.id)
    end
  end

  describe "PATCH /api/v1/user_addresses/:id" do
    it "updates an address and ensures default is unique" do
      ua1 = create(:user_address, user: user, is_default: true,  address: create(:address))
      ua2 = create(:user_address, user: user, is_default: false, address: create(:address))

      patch "/api/v1/user_addresses/#{ua2.id}",
        params: { user_address: { is_default: true } }.to_json,
        headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["is_default"]).to eq(true)
      expect(ua1.reload.is_default).to eq(false)
      expect(ua2.reload.is_default).to eq(true)
      expect($redis.get("user:#{user.id}:addresses")).to be_nil
    end

    it "returns errors for invalid update" do
      ua = create(:user_address, user: user, address: create(:address))

      patch "/api/v1/user_addresses/#{ua.id}",
        params: { user_address: { address_attributes: { address_line: "" } } }.to_json,
        headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/user_addresses/:id" do
    it "deletes the user_address" do
      ua = create(:user_address, user: user, address: create(:address))

      delete "/api/v1/user_addresses/#{ua.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(UserAddress.find_by(id: ua.id)).to be_nil
      expect($redis.get("user:#{user.id}:addresses")).to be_nil
    end

    it "promotes another address to default if default is deleted" do
      ua1 = create(:user_address, user: user, is_default: true,  address: create(:address))
      ua2 = create(:user_address, user: user, is_default: false, address: create(:address))

      delete "/api/v1/user_addresses/#{ua1.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(ua2.reload.is_default).to eq(true)
    end
  end

  describe "GET /api/v1/users/:user_id/user_addresses/default" do
    it "returns the default address of the user" do
      ua = create(:user_address, user: user, is_default: true, address: create(:address))

      get "/api/v1/users/#{user.id}/user_addresses/default", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(ua.id)
    end
  end

  describe "PATCH /api/v1/user_addresses/:id/make_default" do
    it "marks the given address as default and clears others" do
      ua1 = create(:user_address, user: user, is_default: true,  address: create(:address))
      ua2 = create(:user_address, user: user, is_default: false, address: create(:address))

      patch "/api/v1/user_addresses/#{ua2.id}/make_default", headers: headers

      expect(response).to have_http_status(:ok)
      expect(ua1.reload.is_default).to eq(false)
      expect(ua2.reload.is_default).to eq(true)
    end
  end
end
