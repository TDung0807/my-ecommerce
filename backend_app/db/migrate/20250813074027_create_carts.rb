class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end
end
