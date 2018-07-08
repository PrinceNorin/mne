class CreateTaxes < ActiveRecord::Migration[5.1]
  def change
    create_table :taxes do |t|
      t.references :license, foreign_key: true
      t.float :rate
      t.decimal :unit, precision: 16, scale: 6
      t.decimal :total, precision: 16, scale: 6
      t.date :from
      t.date :to
      t.integer :tax_type

      t.timestamps
    end
  end
end
