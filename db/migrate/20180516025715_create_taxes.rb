class CreateTaxes < ActiveRecord::Migration[5.1]
  def change
    create_table :taxes do |t|
      t.references :license, foreign_key: true
      t.decimal :unit, null: false, precision: 16, scale: 6
      t.decimal :total, null: false, precision: 16, scale: 6
      t.integer :year, null: false
      t.integer :month, null: false

      t.timestamps
    end
  end
end
