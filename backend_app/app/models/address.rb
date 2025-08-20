# app/models/address.rb
class Address < ApplicationRecord
  belongs_to :city, optional: true
  belongs_to :country, optional: true

  has_many :user_addresses, dependent: :destroy
  has_many :users, through: :user_addresses
  has_many :orders, dependent: :destroy
end
