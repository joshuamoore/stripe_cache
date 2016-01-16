class AddIndexesToEvent < ActiveRecord::Migration[5.0]
  def up
    add_index :events, :stripe_id

    execute <<-SQL
      CREATE INDEX index_events_on_data_created ON events ((data->>'created'));
      CREATE INDEX index_events_on_data_type ON events ((data->>'type'));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX index_events_on_data_created;
      DROP INDEX index_events_on_data_type;
    SQL
  end
end
