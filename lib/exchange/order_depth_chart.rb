class Excoin::Market::Exchange::OrderDepthChart
  attr_reader :currency, :commodity, :bid_orders, :ask_orders

  def initialize(exchange_name)
    @exchange_name = exchange_name
    exchange = self.exchange

    @currency = exchange.currency
    @commodity = exchange.commodity
    self.update
  end

  def update
    @bid_orders = Array.new
    @ask_orders = Array.new
    self.populate_orders
  end

  def exchange
    return Excoin.market.exchange(@exchange_name)
  end

  protected

    def populate_orders
      data = self.get
      data.each do |order_data|
        order = DataPoint.new(order_data)
        if order.type == "BID"
          @bid_orders << order
        elsif order.type == "ASK"
          @ask_orders << order
        end
      end
    end

    def get
      Excoin.api.exchange_order_depth_chart_data(@currency, @commodity)
    end

end
