class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.integer :zone_id
      t.string :name, :type, :data
      t.integer :ttl
      t.timestamps
    end
  end
end
