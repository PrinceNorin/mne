class CreateLicenses < ActiveRecord::Migration[5.1]
  def change
    create_table :licenses do |t|
      t.string :number, null: false
      t.integer :status, default: 0
      t.decimal :area, null: false
      t.integer :area_unit, default: 0
      t.integer :province, default: 0
      t.date :issued_date, null: false
      t.date :expires_date, null: false
      t.text :address
      t.text :note
      t.string :company_name, null: false
      t.string :owner_name
      t.string :category_name, null: false
      t.references :company, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end
    add_index :licenses, :number, unique: true
  end
end
