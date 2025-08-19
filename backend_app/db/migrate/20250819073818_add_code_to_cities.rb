class AddCodeToCities < ActiveRecord::Migration[8.0]
  def change
    add_column :cities, :code, :string
    add_index  :cities, :code, unique: true
  end
end