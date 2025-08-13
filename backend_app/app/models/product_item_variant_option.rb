class ProductItemVariantOption < ApplicationRecord
  belongs_to :product_item
  belongs_to :variant_option
end
