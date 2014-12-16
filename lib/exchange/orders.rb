class Excoin::Market::Exchange::Orders
  attr_reader :bids, :asks, :all, :orders

  def initialize(exchange)
    @currency = exchange.currency
    @commodity = exchange.commodity
    self.update
  end

  def update(type = nil)
    unless type
      order_data = self.get
      begin
        @orders = self.process_orders(order_data)
        @bids = @orders['bid_orders']
        @asks = @orders['ask_orders']
        @all = self.populate_all
      rescue
        puts "Error in Excoin::Market::Exchange::Orders.update (unless type)"
        puts order_data
      end
    else
      order_data = self.get(type)
      begin
       orders_by_type = self.process_by_type(order_data)
       @orders.merge!(orders_by_type)
       self.set_order_arrays(type)
      rescue
        puts "Error in Excoin::Market::Exchange::Orders.update (else)"
        puts order_data
      end
    end
  end

  def add(new_order)
    begin
      type = new_order.type.downcase
      @orders.select{|k,v| k =~ Regexp.new(type)}[type + "_orders"] << new_order
      if type == "BID"
        @orders.select{|k,v| k =~ Regexp.new(type)}[type + "_orders"].sort_by{|order| order.price}.reverse!
      elsif type == "ASK"
        @orders.select{|k,v| k =~ Regexp.new(type)}[type + "_orders"].sort_by{|order| order.price}
      end
      self.set_order_arrays(new_order.type)
    rescue
      puts "Error in Excoin::Market::Exchange::Orders.add"
      puts new_order
    end
  end

  def remove(order_data)
    begin
      type = order_data['type'].downcase
      @orders.select{|k,v| k =~ Regexp.new(type)}[type + "_orders"].delete_at(@orders.select{|k,v| k =~ Regexp.new(type)}[type + "_orders"].find_index{|order| order.price == BigDecimal.new(order_data['price']) and order.currency_amount == BigDecimal.new(order_data['currency_amount']) and order.commodity_amount == BigDecimal.new(order_data['commodity_amount'])})
      self.set_order_arrays(order_data['type'])
    rescue
      puts "Error in Excoin::Market::Exchange::Orders.remove"
      puts order_data
    end
  end

  def filter(attr, value, operator = :==)
    attr = attr.to_sym
    if attr == :price or attr == :commodity_amount or attr == :currency_amount
      value = BigDecimal.new(value)
    end
    return @all.select{|order| order.send(attr).send(operator, value)}
  end

  def count(attr, value, operator = :==)
    return filter(attr, value, operator).size
  end

  protected

    def get(type = nil)
      Excoin.api.exchange_open_orders(@currency, @commodity, type)
    end

    def process_orders(exchange_order_data)
      exchange_orders = Hash.new
      exchange_order_data.each do |hash_by_type|
        exchange_orders.merge!(process_by_type(hash_by_type))
      end
      return exchange_orders
    end

    def process_by_type(hash_by_type)
      orders_by_type = Array.new
      type = hash_by_type.select{|k,v| k == 'type'}
      hash_by_type['orders'].each do |o|
        o.merge!(type).merge!({"currency" => @currency, "commodity" => @commodity})
        order = Excoin::Market::Exchange::Order.new(o)
        orders_by_type << order
      end
      return { "#{type['type'].downcase}_orders" => orders_by_type }
    end

    def set_order_arrays(type)
      if type.downcase == "bid"
        @bids = @orders[type.downcase + "_orders"]
      elsif type.downcase == "ask"
        @asks = @orders[type.downcase + "_orders"]
      end
      @all = self.populate_all
    end

    def populate_all
      all = Array.new
      @bids.each do |o|
        all << o
      end
      @asks.each do |o|
        all << o
      end
      return all
    end

end
