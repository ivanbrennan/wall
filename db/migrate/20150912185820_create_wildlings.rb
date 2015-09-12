class CreateWildlings < ActiveRecord::Migration
  def change
    create_table :wildlings do |t|
      t.string :name, limit: 32, null: false
    end
  end
end
