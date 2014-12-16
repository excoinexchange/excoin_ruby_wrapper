class Excoin::Account::Trades < Array

  def initialize
    self.update
  end

  def update(count = 100)
    self.clear
    recent_trade_data = self.get(count)
    begin
      recent_trade_data['trades'].each do |trade_data|
        trade = Excoin::Account::Trade.new(trade_data)
        self.push(trade)
      end
    rescue
      puts "Error in Excoin::Account::Trades.update"
      puts recent_trade_data
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
    self.insert(0, Excoin::Account::Trade.new(trade_data))
  end

  def trim(number)
    self.pop(number)
  end

  protected

    def get(count = 100)
      Excoin.api.account_trades(count)
    end

end
