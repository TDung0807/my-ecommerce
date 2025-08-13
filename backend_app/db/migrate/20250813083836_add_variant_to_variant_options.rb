class AddVariantToVariantOptions < ActiveRecord::Migration[8.0]
  def change
    add_reference :variant_options, :variant, null: false, foreign_key: true
  end
end
