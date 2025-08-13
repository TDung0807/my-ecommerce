class AddCartAndProductToCartItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :cart_items, :cart, null: true, foreign_key: true
    add_reference :cart_items, :product, null: true, foreign_key: true

    # Prevent the same product from appearing more than once in the same cart
    add_index :cart_items, [:cart_id, :product_id], unique: true, name: "index_cart_items_on_cart_and_product"
  end
end