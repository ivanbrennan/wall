require 'rails_helper'

describe Castle do
  let(:castle) { build(:castle) }

  it 'has a name' do
    expect(castle.name).to be_present
  end
end
