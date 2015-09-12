class Ranger < ActiveRecord::Base
  has_and_belongs_to_many :castles, join_table: :patrols
end
