class AddObjectIdToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :object_id, :string

    add_index :events, :object_id
  end
end
