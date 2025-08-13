class AddOrderToOrderLines < ActiveRecord::Migration[8.0]
  def change
    add_reference :order_lines, :order, null: false, foreign_key: true

    add_index :order_lines, [:order_id, :product_item_id],
              unique: true,
              name: "index_order_lines_on_order_and_product_item"
  end
end
