require 'rails_helper'

describe Wildling do
  let(:wildling)     { create(:wildling) }

  let(:eastwatch)    { create(:castle, name: 'Eastwatch') }
  let(:castle_black) { create(:castle, name: 'Castle Black') }

  it 'has a name' do
    expect(wildling.name).to be_present
  end

  it 'beseiges castles' do
    wildling.castles << eastwatch
    wildling.castles << castle_black
    expect(wildling.castles).to match_array([eastwatch, castle_black])
  end
end
