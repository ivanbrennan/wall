require 'rails_helper'

describe Castle do
  let(:castle)  { create(:castle) }

  let(:tormund) { create(:wildling, name: 'Tormund') }
  let(:styr)    { create(:wildling, name: 'Styr') }

  let(:grenn)   { create(:ranger, name: 'Grenn') }
  let(:qhorin)  { create(:ranger, name: 'Qhorin') }

  it 'has a name' do
    expect(castle.name).to be_present
  end

  it 'is beseiged by wildlings' do
    castle.wildlings << tormund
    castle.wildlings << styr
    expect(castle.wildlings).to match_array([tormund, styr])
  end

  it 'is patrolled by rangers' do
    castle.rangers << grenn
    castle.rangers << qhorin
    expect(castle.rangers).to match_array([grenn, qhorin])
  end
end
