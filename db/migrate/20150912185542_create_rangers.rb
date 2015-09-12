class CreateRangers < ActiveRecord::Migration
  def change
    create_table :rangers do |t|
      t.string :name, limit: 32, null: false
    end
  end
end
