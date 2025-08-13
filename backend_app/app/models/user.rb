# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::JTIMatcher
  validates :email, presence: true
  validates :password, presence: true

  has_many :user_addresses, dependent: :destroy
  has_one :cart, dependent: :destroy

  after_commit :cache_after_create,  on: :create
  after_commit :cache_after_update,  on: :update
  after_commit :purge_after_destroy, on: :destroy


  
  private

  def cache_after_create
    Services::Redis::Users.new.cache_on_register(self)
  end

  def cache_after_update
    Services::Redis::Users.new.update(self)
  end

  def purge_after_destroy
    Services::Redis::Users.new.delete(self.id)
  end
end
