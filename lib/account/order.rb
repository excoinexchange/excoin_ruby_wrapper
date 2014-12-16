class Excoin::Account::Order
  attr_reader :currency, :commodity, :type, :id, :timestamp, :price,
              :commodity_amount, :currency_amount, :status

  def initialize(order_data)
    self.update(order_data)
  end

  def update(order_data)
    begin
      unless order_data['currency'] and order_data['commodity']
        order_data.merge!({"currency" => order_data['id'].split("-").first, "commodity" => order_data['id'].split("-")[1]})
      end
      @currency ||= order_data['currency']
      @commodity ||= order_data['commodity']
      @type ||= order_data['type']
      @id ||= order_data['id']
      @timestamp ||= Time.parse(order_data['timestamp'])
      @price = BigDecimal.new(order_data['price'])
      @currency_amount = BigDecimal.new(order_data['currency_amount'])
      @commodity_amount = BigDecimal.new(order_data['commodity_amount'])
      @status = order_data['status']
    rescue
      puts "Error in Excoin::Account::Order.update"
      puts order_data
    end
  end

  def exchange
    Excoin.market.exchange(@currency + @commodity)
  end

  def refresh
    order_data = Excoin.api.account_view_order(self.id)
    self.update(order_data)
  end

  def cancel
    order_data = Excoin.api.account_cancel_order(self.id)
    self.update(order_data)
  end

end
