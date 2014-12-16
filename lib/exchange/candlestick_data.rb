class Excoin::Market::Exchange::CandlestickChart::DataPoint
  attr_reader :timestamp, :open, :close, :high, :low, :commodity_volume,
              :currency_volume

  def initialize(exchange_data)
    begin
      @timestamp = Time.parse(exchange_data['timestamp'])
      @open = BigDecimal.new(exchange_data['open'])
      @close = BigDecimal.new(exchange_data['close'])
      @high = BigDecimal.new(exchange_data['high'])
      @low = BigDecimal.new(exchange_data['low'])
      @commodity_volume = BigDecimal.new(exchange_data['commodity_volume'])
      @currency_volume = BigDecimal.new(exchange_data['currency_volume'])
    rescue
      puts "Error in Excoin::Market::Exchange::CandlestickChart::Datapoint"
      puts exchange_data
    end
  end

end
