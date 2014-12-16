class Excoin::Market::Exchange::Trade
  attr_reader :timestamp, :currency, :commodity, :type, :price,
              :commodity_amount, :currency_amount


  def initialize(trade_data)
    begin
      @timestamp = Time.parse(trade_data['timestamp'])
      @currency = trade_data['currency']
      @commodity = trade_data['commodity']
      @type = trade_data['type']
      @price = BigDecimal.new(trade_data['price'])
      @commodity_amount = BigDecimal.new(trade_data['commodity_amount'])
      @currency_amount = BigDecimal.new(trade_data['currency_amount'])
    rescue
      puts "Error in Excoin::Market::Exchange::Trade.initialize"
      puts trade_data
    end
  end

  def exchange
    Excoin.market.exchange(@currency + @commodity)
  end


end
