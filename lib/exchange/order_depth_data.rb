class Excoin::Market::Exchange::OrderDepthChart::DataPoint
  attr_reader :type, :currency_amount, :price

  def initialize(order_data)
    update(order_data)
  end

  protected

    def update(order_data)
      begin
        type_array = order_data.select{|h| h != "price"}.to_a.flatten
        @type = type_array[0]
        @currency_amount = type_array[1]
        @price = BigDecimal.new(order_data['price'])
      rescue
        puts "Error in Excoin::Market::Exchange::OrderDepthChart::DataPoint.update"
        puts order_data
      end
    end

end

