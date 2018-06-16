class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :owner
      t.text :business_address

      t.timestamps
    end
  end
end
