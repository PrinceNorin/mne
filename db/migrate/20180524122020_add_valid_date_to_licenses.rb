class AddValidDateToLicenses < ActiveRecord::Migration[5.1]
  def change
    add_column :licenses, :valid_date, :date, null: false
  end
end
