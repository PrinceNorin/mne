class CreateLicenses < ActiveRecord::Migration[5.1]
  def change
    create_table :licenses do |t|
      t.string :number, null: false
      t.integer :status, default: 0
      t.decimal :total_area, precision: 16, scale: 6, null: false
      t.integer :area_unit, default: 0
      t.integer :province, default: 0
      t.date :issue_at, null: false
      t.date :expire_at, null: false
      t.date :valid_at, null: false
      t.text :business_address
      t.text :note
      t.string :company_name, null: false
      t.string :owner_name
      t.string :category_name, null: false
      t.references :company, foreign_key: true
      t.references :category, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :licenses, :deleted_at
  end
end
