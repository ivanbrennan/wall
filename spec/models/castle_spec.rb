require 'rails_helper'

describe Castle do
  let(:castle)  { create(:castle) }

  let(:tormund) { create(:wildling, name: 'Tormund') }
  let(:styr)    { create(:wildling, name: 'Styr') }

  it 'has a name' do
    expect(castle.name).to be_present
  end

  it 'is beseiged by wildlings' do
    castle.wildlings << tormund
    castle.wildlings << styr
    expect(castle.wildlings).to match_array([tormund, styr])
  end
end
