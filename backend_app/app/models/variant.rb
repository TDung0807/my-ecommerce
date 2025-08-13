class Variant < ApplicationRecord
    belongs_to :product_category, optional: true
    has_many :variant_options, dependent: :destroy
end
