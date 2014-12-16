class Excoin::Market::Exchange
  attr_reader :name, :currency, :commodity, :last_price, :daily_high,
              :daily_low, :daily_volume, :top_bid, :lowest_ask, :orders,
              :trades, :spread

  def initialize(exchange_data)
    begin
      @name = exchange_data['currency'] + exchange_data['commodity']
      @currency = exchange_data['currency']
      @commodity = exchange_data['commodity']

      self.update_summary(exchange_data)
      @orders = Orders.new(self)
      @trades = Trades.new(self)
    rescue
      puts "Error in Excoin::Market::Exchange.initialize"
      puts exchange_data
    end
  end

  def update_summary(exchange_data = nil)
    begin
      exchange_data ||= self.get_summary

      @last_price = BigDecimal.new(exchange_data['last_price'])
      @daily_high = BigDecimal.new(exchange_data['high'])
      @daily_low = BigDecimal.new(exchange_data['low'])
      @daily_volume = BigDecimal.new(exchange_data['volume'])
      @top_bid = BigDecimal.new(exchange_data['top_bid'])
      @lowest_ask = BigDecimal.new(exchange_data['lowest_ask'])
      spread = self.top_bid - self.lowest_ask
      @spread = (spread > 0 ? spread : (spread * -1))
    rescue
      puts "Error in Excoin::Market::Exchange.update_summary"
      puts exchange_data
    end
  end

  def update(exchange_data = nil)
    self.update_summary(exchange_data)
    @orders.update
    @trades.update
  end

  def issue_order(type, amount, price)
    decimal_amount = amount
    if amount.class == String
      decimal_amount = BigDecimal.new(amount)
    end
    if type.upcase == "BID" and (Excoin.account.wallet(self.currency).status == "inactive" or Excoin.account.wallet(self.currency).available_balance < decimal_amount)
      return "Insufficient funds for this order (#{self.currency})"
    elsif type.upcase == "ASK" and (Excoin.account.wallet(self.commodity).status == "inactive" or Excoin.account.wallet(self.commodity).available_balance < decimal_amount)
      return "Insufficient funds for this order (#{self.commodity})"
    else
      begin
        order = Excoin.api.account_issue_order(self.currency, self.commodity, type, amount, price)
        order.merge!({"currency" => self.currency, "commodity" => self.commodity})
        exchange_order = Excoin::Market::Exchange::Order.new(order)
        account_order = Excoin::Account::Order.new(order)
        self.orders.add(exchange_order)
        Excoin.account.orders.add(account_order)
        return account_order.id
      rescue
        puts "Error in Excoin::Market::Exchange.issue_order"
        puts order
      end
    end
  end

  protected
    def get_summary
      Excoin.api(@api_key).exchange_summary(@currency, @commodity)
    end

end
