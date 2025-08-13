class AddCityAndCountryToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_reference :addresses, :city, null: true, foreign_key: true
    add_reference :addresses, :country, null: true, foreign_key: true
  end
end
