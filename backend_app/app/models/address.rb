class Address < ApplicationRecord
    belongs_to :city, optional: true
    belongs_to :country, optional: true
    has_many :user_addresses, dependent: :destroy
    has_many :orders, dependent: :destroy
    belongs_to :user
    belongs_to :address

end
