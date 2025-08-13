class VariantOption < ApplicationRecord
    belongs_to :variant
    has_many :product_item_variant_options, dependent: :destroy
    has_many :product_items, through: :product_item_variant_options
end
