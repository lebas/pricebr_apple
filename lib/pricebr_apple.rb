require "pricebr_apple/version"
require 'nokogiri'
require 'open-uri'

module PricebrApple

	# BR
	# iPhone 6S : http://www.apple.com/br/shop/buy-iphone/iphone6s
	# iPhone 6 : http://www.apple.com/br/shop/buy-iphone/iphone6
  # iPhone 5S : http://www.apple.com/br/shop/buy-iphone/iphone5s
	# MacBook Pro : http://www.apple.com/br/shop/buy-mac/macbook-pro 
  # MacBook Air : http://www.apple.com/br/shop/buy-mac/macbook-air
  # MacBook : http://www.apple.com/br/shop/buy-mac/macbook
  # iMac : http://www.apple.com/br/shop/buy-mac/imac
  # Watch Sport : http://www.apple.com/br/shop/buy-watch/apple-watch-sport
  # Watch : http://www.apple.com/br/shop/buy-watch/apple-watch
  # Watch Edition : http://www.apple.com/br/shop/buy-watch/apple-watch-edition  
  # Apple TV : http://www.apple.com/br/shop/buy-tv/apple-tv

	# EUA 
	# MacBook Pro : http://www.apple.com/shop/buy-mac/macbook-pro

  PRICE_URL = {
    "iPhone 6S" => "http://www.apple.com/br/shop/buy-iphone/iphone6s",
    "iPhone 6" => "http://www.apple.com/br/shop/buy-iphone/iphone6",
    "iPhone 5S" => "http://www.apple.com/br/shop/buy-iphone/iphone5s",
    "MacBook Pro" => "http://www.apple.com/br/shop/buy-mac/macbook-pro", 
    "MacBook Air" => "http://www.apple.com/br/shop/buy-mac/macbook-air",
    "MacBook" => "http://www.apple.com/br/shop/buy-mac/macbook",
    "iMac" => "http://www.apple.com/br/shop/buy-mac/imac",
    "Watch Sport" => "http://www.apple.com/br/shop/buy-watch/apple-watch-sport",
    "Watch" => "http://www.apple.com/br/shop/buy-watch/apple-watch",
    "Watch Edition" => "http://www.apple.com/br/shop/buy-watch/apple-watch-edition",
    "Apple TV" => "http://www.apple.com/br/shop/buy-tv/apple-tv"
  }

  class PriceBR
    def initialize
      @url_price = @model = nil
      @price = 0.0
      @list_partNumber = []
      @country = 'br'
    end

    def set_country(params)
      unless params.nil?
        @country |= params
        @country = '' if @country.equal?('eua')
      end
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

    # params {url_page : 'http://'}
    def get_list_partNumber(params) 
      @list_partNumber |= @page.xpath("//meta[@itemprop='sku']/@content").map {|x| x.value} unless params['url_page'] || @page.nil?
      @list_partNumber
    end

    def update_price 
      PRICE_URL.each do |x,y|
        self.get_list_partNumber({url_page: y})
        @list_partNumber.each do |part|
          self.get_price({url_page: y, partNumber: part})
          puts "#{x} = #{part} = #{self.get_last_price}"
        end
      end
    end

  end
end
