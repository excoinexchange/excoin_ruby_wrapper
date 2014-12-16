require 'spec_helper'

describe Excoin::API do
  subject {Excoin.api}

  describe "multiple_exchange_summary" do
    context "without parameters" do
      it "returns array of exchange hashes", vcr: { cassette_name: 'multi_exchange_summ', match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.multiple_exchange_summary
        expect(response_body).to be_an(Array)
        expect(response_body.first).to be_a(Hash)
      end
    end

    context "with currency parameter" do
      it "returns exchange array by currency", vcr: { cassette_name: 'multi_exchange_summ_currency', match_requests_on: [:method, :uri_without_timestamp] }  do
        response_body = subject.multiple_exchange_summary($currency)
        expect(response_body).to be_an(Array)
        response_body.each do |exchange|
          expect(exchange['currency']).to eq($currency)
        end
      end
    end
  end

  describe "exchange_summary" do
    it "returns exchange summary hash", vcr: { cassette_name: "single_exchange_summary", match_requests_on: [:method, :uri_without_timestamp] } do
      response_body = subject.exchange_summary($currency, $commodity)
      expect(response_body["currency"]).to eq($currency)
      expect(response_body["commodity"]).to eq($commodity)
    end
  end

  describe "exchange_recent_trades" do
    context "without params" do
      it "returns recent trades array", vcr: { cassette_name: "exc_recent_trades", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.exchange_recent_trades($currency, $commodity)
        expect(response_body.has_key?("trades")).to be true
      end
    end
    context "with count limit" do
      it "returns recent trades array", vcr: { cassette_name: "exc_recent_trades_count", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.exchange_recent_trades($currency, $commodity, "count", "5")
        expect(response_body.has_key?("trades")).to be true
        expect(response_body["count"]).to eq(5)
      end
    end
    context "with timestamp limit" do
      it "returns recent trades array", vcr: { cassette_name: "exc_recent_trades_timestamp", match_requests_on: [:method, :uri_without_timestamp], record: :new_episodes } do
        time_utc= Time.now.utc - 24*60*60
        time_limit = time_utc.to_i
        response_body = subject.exchange_recent_trades($currency, $commodity, "timestamp", time_limit)
        response_body["trades"].each do |trade|
          expect(Time.parse(trade["timestamp"])).to be > time_utc
        end
      end
    end
  end

  describe "exchange_open_orders" do
    context "without type parameter" do
      it "returns exchange open orders array", vcr: { cassette_name: "exchange_open_orders", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.exchange_open_orders($currency, $commodity)
        expect(response_body).to be_an(Array)
      end
    end

    context "with type parameter" do
      it "returns exchange open orders array, grouped by type", vcr: { cassette_name: "exchange_open_orders_type", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.exchange_open_orders($currency, $commodity, $type)
        expect(response_body["type"]).to eq($type)
      end
    end
  end

  describe "exchange_candlestick_chart_data" do
    context "without parameters" do
      it "returns array of datapoint hashes", vcr: { cassette_name: "exchange_candlestick_chart_data", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.exchange_candlestick_chart_data($currency, $commodity)
        expect(response_body).to be_an(Array)
        expect(response_body.first).to be_a(Hash)
      end
    end

    context "with duration parameter" do
      it "returns array of datapoint hashes", vcr: { cassette_name: "exchange_candlestick_chart_data_duration", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.exchange_candlestick_chart_data($currency, $commodity, "1D")
        expect(response_body).to be_an(Array)
        expect(Time.parse(response_body.last['timestamp']) - Time.parse(response_body.first['timestamp'])).to be <= 86400
      end
    end
  end

  describe "exchange_order_depth_chart_data" do
    it "returns array of datapoint hashes", vcr: { cassette_name: "exchange_order_depth_chart_data", match_requests_on: [:method, :uri_without_timestamp] } do
      response_body = subject.exchange_order_depth_chart_data($currency, $commodity)
      expect(response_body).to be_an(Array)
      expect(response_body.first).to be_a(Hash)
    end
  end

  describe "account_summary" do
    it "returns account summary array", vcr: { cassette_name: "account_summary", match_requests_on: [:method, :uri_without_timestamp] } do
      response_body = subject.account_summary
      expect(response_body['username']).to be_a(String)
    end
  end

  describe "account_withdraw" do
    it "returns withdrawal hash", vcr: { cassette_name: "account_withdraw", match_requests_on: [:method, :uri_without_timestamp], record: :new_episodes } do
      response_body = subject.account_withdraw($currency, $address, $amount)
      expect(response_body['address']).to eq($address)
      expect(response_body['amount']).to eq($amount)
    end
  end

  describe "account_generate_deposit_address" do
    it "returns hash with address", vcr: { cassette_name: "account_generate_deposit_address", match_requests_on: [:method, :uri_without_timestamp] } do
      response_body = subject.account_generate_deposit_address($commodity)
      expect(response_body['address']).to match(/\A[\S][a-km-zA-HJ-NP-Z0-9]{26,33}\z/)
    end
  end

  describe "account_trades" do
    context "with default count parameter (100)" do
      it "returns hash with counts and trades hashes", vcr: { cassette_name: "account_trades", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.account_trades
        expect(response_body.has_key?("trades")).to be true
        expect(response_body["trades"].size).to be <= 100
        expect(response_body["count"].to_i).to be <= 100
      end
    end

    context "with custom count parameter (#{$count})" do
      it "returns hash with counts and trades hashes", vcr: { cassette_name: "account_trades_count", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.account_trades($count)
        expect(response_body.has_key?("trades")).to be true
        expect(response_body["trades"].size).to be <= $count
        expect(response_body["count"].to_i).to be <= $count
      end
    end
  end

  describe "account_open_orders" do
    context "without parameters" do
      it "returns array of exchange+type hashes", vcr: { cassette_name: "account_open_orders", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.account_open_orders
        expect(response_body).to be_an(Array)
        expect(response_body.first).to be_a(Hash)
      end
    end

    context "with currency and commodity parameters" do
      it "returns hash of bids and asks for the currency and commodity specified", vcr: { cassette_name: "account_open_orders_exchange",
                                                                                          match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.account_open_orders($currency, $commodity)
        expect(response_body["currency"]).to eq($currency)
        expect(response_body["commodity"]).to eq($commodity)
        expect(response_body["orders"].count).to eq(2)
      end
    end

    context "with currency, commodity, and type parameters" do
      it "returns a hash for the currency, commodity, and type specified", vcr: { cassette_name: "account_open_orders_exchange_type",
                                                                                  match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.account_open_orders($currency, $commodity, $type)
        expect(response_body["orders"].first["type"]).to eq($type)
        expect(response_body["currency"]).to eq($currency)
        expect(response_body["commodity"]).to eq($commodity)
        expect(response_body["orders"].count).to eq(1)
      end
    end
  end

  describe "account issue_order" do
    it "returns an order hash", vcr: { cassette_name: "account_issue_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: true } do
      response_body = subject.account_issue_order($currency, $commodity, $type, $amount, $price)
      expect(response_body["type"]).to eq($type)
      expect(BigDecimal.new(response_body["price"])).to eq(BigDecimal.new($price))
      if $type == "BID"
        expect(BigDecimal.new(response_body["currency_amount"])).to eq(BigDecimal.new($amount))
      elsif $type == "ASK"
        expect(BigDecimal.new(response_body["commodity_amount"])).to eq(BigDecimal.new($amount))
      end
    end
  end

  describe "account_view_order" do
    it "returns an order hash matching #{$order_id}", vcr: { cassette_name: "account_view_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: { order_id: $order_id } } do
      response_body = subject.account_view_order($order_id)
      expect(response_body["id"]).to eq($order_id)
    end
  end

  describe "account_cancel_order" do
      it "returns an order hash matching #{$order_id}", vcr: { cassette_name: "account_cancel_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: { order_id: $order_id } } do
        response_body = subject.account_cancel_order($order_id)
        expect(response_body["id"]).to eq($order_id)
        expect(response_body["status"]).to eq("CLOSED")
      end
    end

  describe "excoin_wallets_summary" do
    context "without coin parameter" do
      it "returns array of wallet hashes", vcr: { cassette_name: "excoin_wallets_summary", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.excoin_wallets_summary
        expect(response_body).to be_an(Array)
        expect(response_body.first.has_key?("iso_code")).to be true
      end
    end

    context "with coin parameter" do
      it "returns wallet hash", vcr: { cassette_name: "excoin_wallets_summary_coin", match_requests_on: [:method, :uri_without_timestamp] } do
        response_body = subject.excoin_wallets_summary($currency)
        expect(response_body["iso_code"]).to eq($currency)
      end
    end
  end

  describe "excoin_wallet_reserves(currency)" do
    it "returns a hash with reserve info ", vcr: { cassette_name: "excoin_wallet_reserves", match_requests_on: [:method, :uri_without_timestamp] } do
      response_body = subject.excoin_wallet_reserves($currency)
      expect(response_body["iso_code"]).to eq($currency)
      expect(response_body["hot_addresses"]).to be_an(Array)
    end
  end

end
