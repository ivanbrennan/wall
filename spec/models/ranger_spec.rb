require 'rails_helper'

describe Ranger do
  let(:ranger) { build(:ranger) }

  it 'has a name' do
    expect(ranger.name).to be_present
  end
end
