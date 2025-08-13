class Product < ApplicationRecord
    belongs_to :product_category, optional: true
    has_many :cart_items, dependent: :destroy
    has_many :product_items, dependent: :destroy
end
