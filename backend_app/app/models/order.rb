class Order < ApplicationRecord
    belongs_to :address
    belongs_to :user
    has_many :order_lines, dependent: :destroy
end
