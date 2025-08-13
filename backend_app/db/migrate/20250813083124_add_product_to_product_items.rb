class AddProductToProductItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :product_items, :product, null: true, foreign_key: true

    # Ensure SKU uniqueness within the same product
    add_index :product_items, [:product_id, :sku], unique: true, name: "index_product_items_on_product_and_sku"
  end
end
