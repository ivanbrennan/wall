class Castle < ActiveRecord::Base
  has_and_belongs_to_many :wildlings, join_table: :forays
  has_and_belongs_to_many :rangers,   join_table: :patrols
end
