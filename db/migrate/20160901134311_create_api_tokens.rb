class CreateAPITokens < ActiveRecord::Migration[5.0]
  def change
    create_table :api_tokens do |t|
      t.string :name, :token
      t.datetime :last_used_at
      t.timestamps
    end
  end
end
