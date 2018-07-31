class AddCurrencyToTaxes < ActiveRecord::Migration[5.1]
  def change
    add_column :taxes, :currency, :integer, default: 1
  end
end
