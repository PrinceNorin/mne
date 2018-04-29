class RemoveNumberIndexFromStatement < ActiveRecord::Migration[5.1]
  def change
    remove_index :statements, :number
  end
end
