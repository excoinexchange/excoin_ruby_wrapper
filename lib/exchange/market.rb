class Excoin::Market < Array

  def initialize
    self.refresh_all_data
  end

  def exchanges(currency)
    return self.select{ |e| e.currency == currency }
  end

  def exchange(exchange_name)
    return self.select{ |e| e.name == exchange_name }[0]
  end

  def update
    exchanges_data = self.get_summary
    begin
      exchanges_data.each do |exchange_data|
        if self.select{|e| e.exchange_name == exchange_data['currency'] + exchange_data['commodity']}.empty?
          self.push(Exchange.new(exchange_data))
        else
          exchange.update(exchange_data)
        end
      end
    rescue
      puts "Error in Excoin::Market.update"
      puts exchanges_data
    end
  end

  def update_orders
    self.each do |exchange|
      exchange.orders.update
    end
  end

  def refresh_all_data
    self.clear
    exchanges_data = self.get_summary
    exchanges_data.each do |e|
      self.push(Exchange.new(e))
    end
  end

  protected
    def get_summary
      Excoin.api(@api_key).multiple_exchange_summary
    end

end
