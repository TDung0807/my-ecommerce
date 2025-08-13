class CreateProductItemVariantOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :product_item_variant_options do |t|
      t.references :product_item, null: false, foreign_key: true
      t.references :variant_option, null: false, foreign_key: true

      t.timestamps
    end

    # Prevent the same variant_option from being added twice to the same product_item
    add_index :product_item_variant_options,
              [:product_item_id, :variant_option_id],
              unique: true,
              name: "index_product_item_variant_options_on_item_and_option"
  end
end
