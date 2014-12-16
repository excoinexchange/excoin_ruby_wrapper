class Excoin::Market::Exchange::Order
  attr_reader :currency, :commodity, :type, :price,
              :commodity_amount, :currency_amount

  def initialize(order_data)
    begin
      @currency = order_data['currency']
      @commodity = order_data['commodity']
      @type = order_data['type']
      @price = BigDecimal.new(order_data['price'])
      @commodity_amount = BigDecimal.new(order_data['commodity_amount'])
      @currency_amount = BigDecimal.new(order_data['currency_amount'])
    rescue
      puts "Error in Excoin::Market::Exchange::Order.initialize"
      puts order_data
    end
  end

  def exchange
    return Excoin.market.exchange(@currency + @commodity)
  end

end
