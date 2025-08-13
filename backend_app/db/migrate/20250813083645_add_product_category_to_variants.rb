class AddProductCategoryToVariants < ActiveRecord::Migration[8.0]
  def change
    add_reference :variants, :product_category, null: true, foreign_key: true
  end
end
