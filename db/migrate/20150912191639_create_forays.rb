class CreateForays < ActiveRecord::Migration
  def change
    create_join_table :castles, :wildlings, table_name: :forays do |t|
      t.index [:wildling_id, :castle_id], unique: true
    end
  end
end
