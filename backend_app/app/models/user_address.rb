class UserAddress < ApplicationRecord
  belongs_to :user
  belongs_to :address, inverse_of: :user_addresses, optional: true
  accepts_nested_attributes_for :address
  validates :address_id, uniqueness: { scope: :user_id }, allow_nil: true
end
