class Excoin::Account::Trade
  attr_reader :timestamp, :currency, :commodity, :type, :price, :sent,
              :received, :fee, :net_received

  def initialize(trade_data)
    begin
      @timestamp = Time.parse(trade_data['timestamp'])
      @currency = trade_data['currency']
      @commodity = trade_data['commodity']
      @type = trade_data['type']
      @price = BigDecimal.new(trade_data['price'])
      @sent = BigDecimal.new(trade_data['sent'])
      @received = BigDecimal.new(trade_data['received'])
      @fee = BigDecimal.new(trade_data['fee'])
      @net_received = BigDecimal.new(trade_data['net_received'])
    rescue
      puts "Error in Excoin::Account::Trade.initialize"
      puts trade_data
    end
  end

  def exchange
    Excoin.market.exchange(@currency + @commodity)
  end

end
