# app/models/user_address.rb
class UserAddress < ApplicationRecord
  belongs_to :user
  belongs_to :address, inverse_of: :user_addresses, optional: false

  accepts_nested_attributes_for :address
  validates :address, presence: true
  validates :address_id, uniqueness: { scope: :user_id }
end
