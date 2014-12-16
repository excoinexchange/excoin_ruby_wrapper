class Excoin::Market::Exchange::Trades < Array

  def initialize(exchange)
    @currency = exchange.currency
    @commodity = exchange.commodity
    self.update
  end

  def update(limit_type = "count", limit = 100)
    self.clear
    trade_data = self.get_recent(@currency, @commodity, limit_type, limit)
    begin
      trade_data['trades'].each do |trade|
        self.push(Excoin::Market::Exchange::Trade.new(trade))
      end
    rescue
      puts "Error in Excoin::Market::Exchange::Trades.update"
      puts trade_data
    end
  end

  def buys
    self.select{|trade| trade.type == "BUY"}
  end

  def sells
    self.select{|trade| trade.type == "SELL"}
  end

  def highest(type = nil)
    unless type
      self.max_by{|trade| trade.price}
    else
      self.select{|trade| trade.type == type.upcase}.max_by{|trade| trade.price}
    end
  end

  def lowest(type = nil)
    unless type
      self.min_by{|trade| trade.price}
    else
      self.select{|trade| trade.type == type.upcase}.min_by{|trade| trade.price}
    end
  end

  def add(trade_data)
    begin
      unless trade_data.has_key?("currency")
        trade_data.merge!({"currency" => @currency, "commodity" => @commodity})
      end
      self.insert(0, Excoin::Market::Exchange::Trade.new(trade_data))
    rescue
      puts "Error in Excoin::Market::Exchange::Trades.add"
      puts trade_data
    end
  end

  def trim(number)
    self.pop(number)
  end

  protected

    def get_recent(currency, commodity, limit_type = "count", limit = 100)
      Excoin.api.exchange_recent_trades(currency, commodity, limit_type, limit)
    end

end
