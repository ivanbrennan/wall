require 'rails_helper'

describe Ranger do
  let(:ranger)       { create(:ranger) }

  let(:eastwatch)    { create(:castle, name: 'Eastwatch') }
  let(:castle_black) { create(:castle, name: 'Castle Black') }

  it 'has a name' do
    expect(ranger.name).to be_present
  end

  it 'patrols castles' do
    ranger.castles << eastwatch
    ranger.castles << castle_black
    expect(ranger.castles).to match_array([eastwatch, castle_black])
  end
end
