class CreateProductItems < ActiveRecord::Migration[8.0]
  def change
    create_table :product_items do |t|
      t.string  :sku, null: false
      t.integer :qty_in_stock, null: false, default: 0
      t.string  :image
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    add_index :product_items, :sku, unique: true
  end
end
