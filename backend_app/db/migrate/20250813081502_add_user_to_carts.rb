class AddUserToCarts < ActiveRecord::Migration[8.0]
  # Needed for concurrent index operations on Postgres
  disable_ddl_transaction!

  def up
    # 1) Add column/foreign key if missing (safe re-run)
    unless column_exists?(:carts, :user_id)
      add_reference :carts, :user, null: true, foreign_key: true, index: false
    end

    # 2) Backfill only rows still NULL (safe re-run)
    execute <<-SQL.squish
      UPDATE carts
      SET user_id = subq.id
      FROM (SELECT id FROM users ORDER BY id LIMIT 1) AS subq
      WHERE user_id IS NULL
    SQL

    # 3) Enforce NOT NULL (safe if already NOT NULL)
    change_column_null :carts, :user_id, false

    # 4) Ensure UNIQUE index on user_id
    if index_exists?(:carts, :user_id, unique: true, name: "index_carts_on_user_id")
      # already unique — nothing to do
    else
      # If a non-unique index exists, drop it first (concurrently)
      if index_exists?(:carts, :user_id, name: "index_carts_on_user_id")
        remove_index :carts, name: "index_carts_on_user_id", algorithm: :concurrently
      end
      add_index :carts, :user_id, unique: true, algorithm: :concurrently, name: "index_carts_on_user_id"
    end
  end

  def down
    # Reverse in the safest order
    remove_index :carts, name: "index_carts_on_user_id" if index_exists?(:carts, name: "index_carts_on_user_id")
    change_column_null :carts, :user_id, true if column_exists?(:carts, :user_id)
    remove_foreign_key :carts, :users if foreign_key_exists?(:carts, :users)
    remove_column :carts, :user_id if column_exists?(:carts, :user_id)
  end
end
