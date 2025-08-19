class AddUniqueIndexOnUserAddresses < ActiveRecord::Migration[8.0]
  def change
    add_index :user_addresses, [:user_id, :address_id],
              unique: true,
              where: "address_id IS NOT NULL",
              name: "index_user_addresses_on_user_and_address"
  end
end
