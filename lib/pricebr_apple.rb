require 'pricebr_apple/version'
require 'nokogiri'
require 'open-uri'
require 'pry'

module PricebrApple
	# EUA 
	# MacBook Pro : http://www.apple.com/shop/buy-mac/macbook-pro
  PRICE_URL = {
    "IPHONE 6S" => "http://www.apple.com/br/shop/buy-iphone/iphone6s#00",
    "IPHONE 6S PLUS" => "http://www.apple.com/br/shop/buy-iphone/iphone6s#01",
    "IPHONE SE" => "http://www.apple.com/br/shop/buy-iphone/iphone-se",
    "IPHONE 7" => "http://www.apple.com/br/shop/buy-iphone/iphone-7#00",
    "IPHONE 7 PLUS" => "http://www.apple.com/br/shop/buy-iphone/iphone-7#01",
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
    "WATCH SERIE 2" => "http://www.apple.com/br/shop/buy-watch/apple-watch",
    "WATCH SERIE 2 EDITION" =>"http://www.apple.com/br/shop/buy-watch/apple-watch/branco-cer%C3%A2mica-nuvem-pulseira-esportiva?product=MNPF2BZ/A&step=detail",
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
    	if !url_page.nil? && !@model.nil?
    		@page = Nokogiri::HTML(open(url_page))
    		list_price = @page.css('.current_price')
        list_price = @page.css('.as-price-currentprice') if list_price.empty?
    		unless list_price.nil?
    			list_price.map{|item| @price = item.children[1].children[3].children[0].text.gsub(' ', '').gsub("\nR$",'').gsub("\n",'').gsub('.','').gsub(',','.').to_f if !item.nil? && item.children[1].children[1].values[1].to_s == @model}
        else
          @price = 0.0
    		end
    	end 
    	@price
    end

  	def get_last_price
  		@price
  	end

    # params {script:  'text', partNumber:  'model'}
    def script_crawler(params)
      list = []
      download = open(params[:url_page]) unless params[:url_page].nil?
      unless download.nil?
        download.each do |line|
          if !line.nil? && (line.include? 'partNumber') && (line.include? 'currentPrice')
            frame = line.split('"products"')
            frame = frame.last.split('"dimensionCapacity"')
            frame.each do |item|
              if !item.nil? && (item.include? 'partNumber') && (item.include? 'price')
                part = item.split('partNumber')
                if part.size == 2
                  partNumber, part = part[1].split('seoUrlToken')
                  unless part.nil?
                    part = part.split('carrierPolicyPart').first
                    price = part.split('price').last
                    price = self.cleaning(price)
                  end
                  partNumber = self.cleaning(partNumber)
                  list << [ partNumber, price.to_f ] if !partNumber.nil? && !price.nil?
                end
              end
            end 
          end
        end
      end
      return list.empty? ? nil : list 
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
        new_format = ["IPHONE 7 PLUS", "IPHONE 7", "IPHONE 6S", "IPHONE 6S PLUS", "IPHONE SE", "WATCH SERIES 1", "WATCH SERIE 2", "WATCH SERIE 2 EDITION"]
        if (new_format.include? x)
          sub_list = script_crawler({url_page: y})
          list = list + sub_list unless sub_list.nil?
        else 
          get_list_partNumber({url_page: y})
          @list_partNumber.each do |part|
            self.get_price({url_page: y, partNumber: part})
            list << [ part, self.get_last_price ]
          end
        end
      end
      return list
    end

    def cleaning(str = nil)
      str.to_s.gsub('"','').gsub(':','').gsub(',','').gsub('_','.') unless str.nil?
    end
  end
end
