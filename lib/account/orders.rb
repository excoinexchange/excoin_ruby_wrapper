class Excoin::Account::Orders < Array

  def initialize
    self.refresh
  end

  def update(exchange_name = nil)
    begin
      unless exchange_name
        all_orders = populate_all_orders
        all_orders.each do |exchange_order_set|
          self.select{|h| h['exchange_name'] == exchange_order_set['exchange_name']}.first.merge!(exchange_order_set)
        end
      else
        exchange = Excoin.market.exchange(exchange_name)
        exchange_order_data = self.get(exchange.currency, exchange.commodity)
        exchange_orders = self.process_orders_by_exchange(exchange_order_data)
        self.select{|h| h['currency'] == currency and h['commodity'] == commodity}.first.merge!(exchange_orders)
      end
    rescue
      puts "Error in Excoin::Account::Orders.update"
      puts exchange_order_data
    end
  end

  def refresh
    self.clear
    all_orders = self.populate_all_orders
    all_orders.each do |exchange_order_set|
      self.push(exchange_order_set)
    end
  end

  def all
    self.collect{|order_set| order_set.select{|k,v| k =~ Regexp.new("_orders")}.values}.collect{|orders| orders}.flatten
  end

  def add(order)
    begin
      self.select{|exchange_order_set| exchange_order_set.has_value?(order.currency + order.commodity)}[0].select{|k,v| k =~ Regexp.new(order.type.downcase)}[order.type.downcase + "_orders"] << order
    rescue
      puts "Error in Excoin::Account::Orders.add"
      puts order
    end
  end

  def delete(order_data)
    begin
      self.select{|exchange_order_set| exchange_order_set.has_value?(order_data['currency'] + order_data['commodity'])}[0].select{|k,v| k =~ Regexp.new(order_data['type'].downcase)}[order_data['type'].downcase + "_orders"].delete_at(self.select{|exchange_order_set| exchange_order_set.has_value?(order_data['currency'] + order_data['commodity'])}[0].select{|k,v| k =~ Regexp.new(order_data['type'].downcase)}[order_data['type'].downcase + "_orders"].find_index{|order| order.id == order_data['id']})
    rescue
      puts "Error in Excoin::Account::Orders.delete"
      puts order_data
    end
  end

  def filter(attr, value, operator = :==)
    orders_by_attr = Array.new
    if attr == "currency" or attr == "commodity" or attr == "exchange_name"
      self.select{|h| h[attr] == value}.each do |h|
        h.select{|k,v| k =~ Regexp.new("_orders")}.each_value do |orders|
          orders.each do |order|
            orders_by_attr << order
          end
        end
      end
    else
      self.each do |h|
        if attr == "type"
          h.select{|k,v| k =~ Regexp.new(value.upcase)}.each_value do |orders|
            orders.each do |order|
              orders_by_attr << order
            end
          end
        else
          h.select{|k,v| k =~ Regexp.new("_orders")}.each_value do |orders|
            orders.each do |order|
              value = BigDecimal.new(value)
              if order.send(attr).send(operator, value)
                orders_by_attr << order
              end
            end
          end
        end
      end
    end
    return orders_by_attr
  end

  def count(attr = nil, value = nil, operator = :==)
    if attr
      return self.filter(attr, value, operator).size
    else
      count = 0
      self.each do |h|
      # maybe this can be redone with inject
        h.select{|k,v| k =~ /_orders/}.each_pair do |k,v|
          count += v.size
        end
      end
      return count
    end
  end

  protected

    def get(currency = nil, commodity = nil, type = nil)
      Excoin.api.account_open_orders(currency, commodity, type)
    end

    def process_orders_by_exchange(exchange_order_data)
      begin
        currency = exchange_order_data.select{|k,v| k == 'currency'}
        commodity = exchange_order_data.select{|k,v| k == 'commodity'}
        exchange_orders = {"exchange_name" => currency['currency'] + commodity['commodity']}.merge(currency).merge(commodity)
        exchange_order_data['orders'].each do |hash_by_type|
          orders_by_type = Array.new
          type = hash_by_type.select{|k,v| k == 'type'}
          hash_by_type['orders'].each do |o|
            o.merge!(type).merge!(currency).merge!(commodity)
            order = Excoin::Account::Order.new(o)
            orders_by_type << order
          end
          exchange_orders.merge!({ "#{type['type'].downcase}_orders" => orders_by_type})
        end
        return exchange_orders
      rescue
        puts "Error in Excoin::Account::Orders.process_orders_by_exchange"
        puts exchange_order_data
      end
    end

  def populate_all_orders
    order_data = self.get
    orders = order_data.collect{|exchange_order_data| self.process_orders_by_exchange(exchange_order_data)}
    return orders
  end

end
