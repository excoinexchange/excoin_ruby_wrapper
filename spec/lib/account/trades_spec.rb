require 'spec_helper'

describe Excoin::Account::Orders do
  subject {Excoin.account.trades}

  it "is an Excoin::Account::Trades object" do
    expect(subject).to be_an(Excoin::Account::Trades)
  end

  it "has complete Excoin::Account::Trade objects" do
    expect(subject.first).to be_an(Excoin::Account::Trade)
    expect(subject.first.timestamp).to be_a(Time)
    expect(subject.first.currency).to be_a(String)
    expect(subject.first.commodity).to be_a(String)
    expect(subject.first.type).to be_a(String)
    expect(subject.first.price).to be_a(BigDecimal)
    expect(subject.first.sent).to be_a(BigDecimal)
    expect(subject.first.received).to be_a(BigDecimal)
    expect(subject.first.fee).to be_a(BigDecimal)
    expect(subject.first.net_received).to be_a(BigDecimal)
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
    expect(subject.highest).to be_an(Excoin::Account::Trade)
    expect(subject.highest("sell")).to be_an(Excoin::Account::Trade)
  end

  it "trim(n) removes n trades" do
    initial_size = subject.size
    subject.trim(1)
    expect(subject.size).to eq(initial_size - 1)
  end

  it "add(trade_data) adds a new Trade object" do
    subject.add($trade_data)
    expect(subject.select{|trade| trade.timestamp == Time.parse($trade_data['timestamp'])}.first).to be_an(Excoin::Account::Trade)
  end
end
