class AddTaxTypeToTaxes < ActiveRecord::Migration[5.1]
  def change
    add_column :taxes, :tax_type, :integer, null: false
  end
end
