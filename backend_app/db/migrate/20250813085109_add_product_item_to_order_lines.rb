class AddProductItemToOrderLines < ActiveRecord::Migration[8.0]
  def change
    add_reference :order_lines, :product_item, null: false, foreign_key: true
  end
end
