class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :unit_number
      t.string :street_number
      t.string :region
      t.string :address_line

      t.timestamps
    end
  end
end
