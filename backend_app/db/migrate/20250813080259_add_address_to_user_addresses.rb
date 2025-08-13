class AddAddressToUserAddresses < ActiveRecord::Migration[8.0]
  def change
    add_reference :user_addresses, :address, null: true, foreign_key: true
  end
end