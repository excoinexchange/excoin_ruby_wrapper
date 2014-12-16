require 'yaml'
require 'json'
require 'webmock/rspec'
require 'vcr'

require File.expand_path('../lib/excoin.rb', File.dirname(__FILE__))
Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each { |f| require f }

# API settings
  config = YAML::load_file(File.expand_path('../../config/config.yml', __FILE__))
  $api_key = config["API_key"]
  $currency = "BTC"
  $commodity = "BLK"
  $type = "BID"
  $count = 25

  VCR.use_cassette("account_summary", match_requests_on: [:method, :uri_without_timestamp]) do
    account = Excoin.api.account_summary
    wallet = account["active_wallets"].select{ |h| h["currency"] == $currency }.first
    $amount = wallet["available_balance"]
    $address = wallet["address"]
    VCR.use_cassette("single_exchange_summary", match_requests_on: [:method, :uri_without_timestamp]) do
      if $type == "BID"
        $price = Excoin.api.exchange_summary($currency, $commodity)["top_bid"]
      else
        $price = Excoin.api.exchange_summary($currency, $commodity)["lowest_ask"]
      end
    end
  end

  VCR.use_cassette("account_view_order", match_requests_on: [:method, :uri_without_timestamp], record: :new_episodes) do
    orders = Excoin.api.account_open_orders($currency, $commodity)
    $order = orders['orders'].first['orders'].first
    $order_id =  $order['id']
    $order_data = JSON.parse('{"id":"BTC-BLK-BID-NewOrderlKmc4gDXKc","timestamp":"2014-07-21 19:06:45 UTC","type":"BID","price":"0.00035","commodity_amount":"4.5","currency_amount":"0.00157500","status":"pending"}')
  end

# Trade test data
  $trade_data = JSON.parse('{"action":"trade","timestamp":"2014-07-21 19:06:45 UTC","unix_timestamp":"1405969605","currency":"BTC","currency_name":"Bitcoin","commodity":"BLK","commodity_name":"Blackcoin","type":"BUY","price":"0.00000032","sent":"0.09478962","received":"412128.80177019","fee":"618.19320265","net_received":"411510.60856753"}')
  $exchange_trade_data = JSON.parse('{"action":"trade","timestamp":"2014-07-21 19:06:45 UTC","unix_timestamp":"1405969605","type":"BUY","price":"0.00000032","currency_amount":"0.09478962","commodity_amount":"412128.80177019"}')

RSpec.configure do |c|
  c.color = true
end


