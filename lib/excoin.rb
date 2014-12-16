module Excoin
  require "time"
  require "bigdecimal"
  require "bigdecimal/util"
  require "excoin/api"
  require "account/account"
  require "account/wallet"
  require "account/deposit"
  require "account/withdrawal"
  require "account/orders"
  require "account/order"
  require "account/trades"
  require "account/trade"
  require "exchange/market"
  require "exchange/exchange"
  require "exchange/orders"
  require "exchange/order"
  require "exchange/trades"
  require "exchange/trade"
  require "exchange/order_depth_chart"
  require "exchange/order_depth_data"
  require "exchange/candlestick_chart"
  require "exchange/candlestick_data"


  def self.account
    self.api if @api.nil?
    @account ||= Account.new
  end

  def self.exchange(exchange_name)
    self.api if @api.nil?
    @exchange ||= self.market.exchange(exchange_name)
  end

  def self.market
    self.api if @api.nil?
    @market ||= Market.new
  end

  def self.api(api_key = nil, api_secret = nil, replay_strategy = nil, strategy_parameter = nil)
     @api ||= API.new(api_key, api_secret, replay_strategy, strategy_parameter)
  end

end
