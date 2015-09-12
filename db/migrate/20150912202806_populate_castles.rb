class PopulateCastles < ActiveRecord::Migration
  class Castle < ActiveRecord::Base
  end

  def change
    ['Castle Black', 'Shadow Tower', 'Eastwatch'].each do |name|
      Castle.where(name: name).first_or_create!
    end
  end
end
