class Castle < ActiveRecord::Base
  has_and_belongs_to_many :wildlings, join_table: :forays
end
