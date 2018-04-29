class ChangeLincesesArea < ActiveRecord::Migration[5.1]
  def change
    change_column :licenses, :area, :decimal, precision: 16, scale: 6
  end
end
