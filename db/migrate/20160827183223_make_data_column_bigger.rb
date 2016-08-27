class MakeDataColumnBigger < ActiveRecord::Migration[5.0]
  def up
    change_column :records, :data, :string, :limit => 4096
  end

  def down
    change_column :records, :data, :string, :limit => 255
  end
end
