class CreateUserAddresses < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TYPE address_default_status AS ENUM ('true', 'false');
    SQL

    create_table :user_addresses do |t|
      t.column :is_default, :address_default_status, null: false, default: 'false'
    end
  end

  def down
    drop_table :user_addresses
    execute <<-SQL
      DROP TYPE address_default_status;
    SQL
  end
end
