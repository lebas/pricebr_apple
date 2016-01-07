require 'spec_helper'

describe PricebrApple do
  it 'has a version number' do
    expect(PricebrApple::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end

  it 'get list price' do
  price =  PricebrApple::PriceBR.new
  list = price.update_price
  expect(list).not_to be nil
end
