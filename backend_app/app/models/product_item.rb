class ProductItem < ApplicationRecord
    belongs_to :product
    has_many :product_item_variant_options, dependent: :destroy
    has_many :variant_options, through: :product_item_variant_options
    has_many :order_lines, dependent: :restrict_with_error
end
