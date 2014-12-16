require 'spec_helper'

describe Excoin::Market::Exchange::Trades, vcr: { cassette_name: "exc_recent_trades", match_requests_on: [:method, :uri_without_timestamp] } do
  subject {Excoin.market.exchange($currency + $commodity).trades}

  it "is a complete Excoin::Market::Exchange::Trades object" do
    expect(subject).to be_an(Excoin::Market::Exchange::Trades)
  end

  it "has complete Excoin::Market::Exchange::Trade objects" do
    expect(subject.first).to be_an(Excoin::Market::Exchange::Trade)
    expect(subject.first.timestamp).to be_a(Time)
    expect(subject.first.currency).to be_a(String)
    expect(subject.first.commodity).to be_a(String)
    expect(subject.first.type).to be_a(String)
    expect(subject.first.price).to be_a(BigDecimal)
    expect(subject.first.commodity_amount).to be_a(BigDecimal)
    expect(subject.first.currency_amount).to be_a(BigDecimal)
  end

  it "buys returns all buy trades" do
    expect(subject.buys).to be_an(Array)
    subject.buys.each do |trade|
      expect(trade.type).to eq("BUY")
    end
  end

  it "sells returns all sell trades" do
    expect(subject.sells).to be_an(Array)
    subject.sells.each do |trade|
      expect(trade.type).to eq("SELL")
    end
  end

  it "highest returns highest priced trade" do
    expect(subject.highest).to be_an(Excoin::Market::Exchange::Trade)
    expect(subject.highest("sell")).to be_an(Excoin::Market::Exchange::Trade)
  end

  it "trim(n) removes n trades" do
    initial_size = subject.size
    subject.trim(1)
    expect(subject.size).to eq(initial_size - 1)
  end

  it "add(trade_data) adds a new Trade object" do
    subject.add($exchange_trade_data)
    expect(subject.select{|trade| trade.timestamp == Time.parse($trade_data['timestamp'])}.first).to be_an(Excoin::Market::Exchange::Trade)
  end
end
