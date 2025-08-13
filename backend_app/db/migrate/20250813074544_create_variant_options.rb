class CreateVariantOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :variant_options do |t|
      t.string :value, null: false

      t.timestamps
    end
  end
end
