class CreateCastles < ActiveRecord::Migration
  def change
    create_table :castles do |t|
      t.string :name, limit: 32, null: false
    end
  end
end
