class CreateStatements < ActiveRecord::Migration[5.1]
  def change
    create_table :statements do |t|
      t.string :number
      t.bigint :reference_id
      t.references :license, foreign_key: true
      t.date :issued_date
      t.integer :statement_type, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :statements, :number, unique: true
    add_index :statements, :reference_id, unique: true
    add_index :statements, :deleted_at
  end
end
