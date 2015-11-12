require "pricebr_apple/version"
require 'nokogiri'
require 'open-uri'

module PricebrApple

	# BR
	# iPhone 6S : http://www.apple.com/br/shop/buy-iphone/iphone6s
	# iPhone 6 : http://www.apple.com/br/shop/buy-iphone/iphone6
	# MacBook Pro : http://www.apple.com/br/shop/buy-mac/macbook-pro 

	# EUA 
	# MacBook Pro : http://www.apple.com/shop/buy-mac/macbook-pro

  class PriceBR
    def initialize
      @url_price = @model = nil
      @price = 0.0
    end

    # params {url_page:  'http://', partNumber:  'model'}
    def get_price(params)
    	@url_price = params['url_page']
    	@model = params['partNumber']
    	unless @url_price.nil? || @model.nil?
    		@page = Nokogiri::HTML(open(@url_page))
    		list_price = @page.css('.current_price')
    		unless list_price.nil?
    			list_price.map{|item| @price = item.children[1].children[5].text.gsub(' ', '').gsub("\nR$",'').gsub("\n",'').gsub('.','').gsub(',','.').to_f if item.children[1].children[1].values[1].to_s == @model}
    		end
    	end 
    	@price
    end

  	def get_last_price
  		@price
  	end

  end
end
