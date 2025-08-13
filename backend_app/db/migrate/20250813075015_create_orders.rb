class CreateOrders < ActiveRecord::Migration[8.0]
  def up
    # Create the enum type in PostgreSQL
    execute <<-SQL
      CREATE TYPE order_status AS ENUM ('shipping', 'canceled', 'successful');
    SQL

    create_table :orders do |t|
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0.0
      t.column :order_status, :order_status, null: false, default: 'shipping'

      t.timestamps
    end
  end

  def down
    drop_table :orders
    execute <<-SQL
      DROP TYPE order_status;
    SQL
  end
end
