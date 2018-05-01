class CreateBusinessPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :business_plans do |t|
      t.references :license, foreign_key: true
      t.integer :currency, default: 0
      t.text :content
      t.decimal :budget, precision: 16, scale: 6, default: 0
      t.integer :employees
      t.text :note

      t.timestamps
    end
  end
end
