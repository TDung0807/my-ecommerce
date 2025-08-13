class AddUserToUserAddresses < ActiveRecord::Migration[8.0]
  def change
    add_reference :user_addresses, :user, null: true, foreign_key: true
  end
end
