class OrderLine < ApplicationRecord
    belongs_to :order
    belongs_to :product_item
end
