class RemoveNumberIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :licenses, :number
  end
end
