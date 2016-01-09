class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.integer :stripe_id
      t.json :data

      t.timestamps
    end
  end
end
