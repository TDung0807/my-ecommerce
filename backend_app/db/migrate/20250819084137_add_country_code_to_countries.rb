class AddCountryCodeToCountries < ActiveRecord::Migration[8.0]
  def change
    add_column :countries, :country_code, :string
    add_index  :countries, :country_code, unique: true
  end
end
