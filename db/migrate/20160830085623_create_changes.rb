class CreateChanges < ActiveRecord::Migration[5.0]
  def change
    create_table :changes do |t|
      t.integer :zone_id, :user_id
      t.string :event
      t.string :name
      t.string :attribute_name
      t.string :old_value, :limit => 4096
      t.string :new_value, :limit => 4096
      t.datetime :published_at
      t.integer :serial
      t.timestamps
    end
  end
end
