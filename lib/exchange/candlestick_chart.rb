class Excoin::Market::Exchange::CandlestickChart
  attr_reader :currency, :commodity, :datapoints

  def initialize(exchange_name)
    @exchange_name = exchange_name
    exchange = self.exchange

    @currency = exchange.currency
    @commodity = exchange.commodity

    @datapoints = Array.new
    self.update
  end

  def update
    @datapoints.clear
    chart_data = self.get
    chart_data.each do |point|
      datapoint = DataPoint.new(point)
      @datapoints << datapoint
    end
  end

  def exchange
    return Excoin.market.exchange(@exchange_name)
  end

  protected
    def get
      Excoin.api.exchange_candlestick_chart_data(@currency, @commodity)
    end

end
