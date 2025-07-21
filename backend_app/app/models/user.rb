# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,          # For sign-up
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
  validates :email, presence: true
  validates :password, presence: true
end
