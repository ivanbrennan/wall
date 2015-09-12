require 'rails_helper'

describe Wildling do
  let(:wildling) { build(:wildling) }

  it 'has a name' do
    expect(wildling.name).to be_present
  end
end
