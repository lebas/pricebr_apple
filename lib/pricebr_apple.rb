require 'pricebr_apple/version'
require 'nokogiri'
require 'open-uri'
require 'pry'

module PricebrApple
	# EUA 
	# MacBook Pro : http://www.apple.com/shop/buy-mac/macbook-pro
  PRICE_URL = {
    "IPHONE 6S" => "http://www.apple.com/br/shop/buy-iphone/iphone6s",
    "IPHONE SE" => "http://www.apple.com/br/shop/buy-iphone/iphone-se",
    "IPHONE 5S" => "http://www.apple.com/br/shop/buy-iphone/iphone5s",
    "MACBOOK PRO" => "http://www.apple.com/br/shop/buy-mac/macbook-pro", 
    "MACBOOK AIR" => "http://www.apple.com/br/shop/buy-mac/macbook-air",
    "MACBOOK" => "http://www.apple.com/br/shop/buy-mac/macbook",
    "IMAC" => "http://www.apple.com/br/shop/buy-mac/imac",
    "APPLE TV" => "http://www.apple.com/br/shop/buy-tv/apple-tv",
    "IPAD PRO" => "http://www.apple.com/br/shop/buy-ipad/ipad-pro",
    "IPAD AIR 2" => "http://www.apple.com/br/shop/buy-ipad/ipad-air-2",
    "IPAD MINI 4" => "http://www.apple.com/br/shop/buy-ipad/ipad-mini-4",
    "IPAD MINI 2" => "http://www.apple.com/br/shop/buy-ipad/ipad-mini-2",
    "WATCH SERIES 1" => "http://www.apple.com/br/shop/buy-watch/apple-watch-series-1",
    "WATCH" => "http://www.apple.com/br/shop/buy-watch/apple-watch",
  }

  class PriceBR
    def initialize
      @model = nil
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

    # params {url_page:  'device page', partNumber:  'model'}
    def get_price(params)
    	@model = params[:partNumber]
      url_page = params[:url_page]
    	if  !url_page.nil? && !@model.nil?
    		@page = Nokogiri::HTML(open(url_page))
    		list_price = @page.css('.current_price')
    		unless list_price.nil?
    			list_price.map{|item| @price = item.children[1].children[3].children[0].text.gsub(' ', '').gsub("\nR$",'').gsub("\n",'').gsub('.','').gsub(',','.').to_f if !item.nil? && item.children[1].children[1].values[1].to_s == @model}
    		end
    	end 
    	@price
    end

  	def get_last_price
  		@price
  	end

    # params {url_page : 'http://'}
    def get_list_partNumber(params) 
      unless params[:url_page].nil?
        @page = Nokogiri::HTML(open(params[:url_page]))
        @list_partNumber = @page.xpath("//meta[@itemprop='sku']/@content").map {|x| x.value} unless @page.nil?
      end
      @list_partNumber
    end

    def update_price
      list = []
      PRICE_URL.each do |x,y|
        get_list_partNumber({url_page: y})
        @list_partNumber.each do |part|
          self.get_price({url_page: y, partNumber: part})
          list << [ part, self.get_last_price ]
        end
      end
      return list
    end
  end
end
