require 'spec_helper'

describe PricebrApple do
  it 'has a version number' do
    expect(PricebrApple::VERSION).not_to be nil
  end

  #it 'does something useful' do
  #expect(false).to eq(true)
  #end

  context ' get list price' do
    price =  PricebrApple::PriceBR.new
    list = price.update_price

    it 'list not nil' do
      expect(list).not_to be nil
    end

    it 'get price non zero' do
      list.each do |partnumber, price|
        puts "PN: #{partnumber} => Price #{price}"
        expect(partnumber).not_to be nil
        expect(price).to satisfy { |v| v > 0 }
      end
    end
  end
end
