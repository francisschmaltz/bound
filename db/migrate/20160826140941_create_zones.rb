class CreateZones < ActiveRecord::Migration[5.0]
  def change
    create_table :zones do |t|
      t.string :name, :primary_ns, :email_address
      t.integer :serial, :refresh_time, :retry_time, :expiration_time, :max_cache, :ttl
      t.datetime :published_at
      t.timestamps
    end
  end
end
