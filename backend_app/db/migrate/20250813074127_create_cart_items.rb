class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items do |t|
      t.integer :qty, null: false, default: 1

      t.timestamps
    end
  end
end
