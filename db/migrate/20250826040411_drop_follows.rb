class DropFollows < ActiveRecord::Migration[8.0]
  def change
    drop_table :follows if table_exists?(:follows)
  end
end
