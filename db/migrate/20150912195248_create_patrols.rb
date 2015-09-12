class CreatePatrols < ActiveRecord::Migration
  def change
    create_join_table :castles, :rangers, table_name: :patrols do |t|
      t.index [:ranger_id, :castle_id], unique: true
    end
  end
end
