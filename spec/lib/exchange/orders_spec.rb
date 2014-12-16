require 'spec_helper'

describe Excoin::Market::Exchange::Orders, vcr: { cassette_name: "exchange_open_orders", match_requests_on: [:method, :uri_without_timestamp] } do
  subject {Excoin.market.exchange($currency + $commodity).orders}

  it "is a complete Excoin::Market::Exchange::Orders object" do
    expect(subject).to be_an(Excoin::Market::Exchange::Orders)
  end

  it "has complete Excoin::Market::Exchange::Order objects" do
    expect(subject.all.first).to be_an(Excoin::Market::Exchange::Order)
    expect(subject.all.first.currency).to be_a(String)
    expect(subject.all.first.commodity).to be_a(String)
    expect(subject.all.first.type).to be_a(String)
    expect(subject.all.first.price).to be_a(BigDecimal)
    expect(subject.all.first.commodity_amount).to be_a(BigDecimal)
    expect(subject.all.first.currency_amount).to be_a(BigDecimal)
  end

  it "adds order to Orders" do
    order = Excoin::Market::Exchange::Order.new($order_data)
    expect(subject.all).to_not include(order)
    subject.add(order)
    expect(subject.all).to include(order)
  end

  it "remove removes matching order from Orders" do
    order = Excoin::Market::Exchange::Order.new($order_data)
    subject.add(order)
    initial_size = subject.all.size
    subject.remove($order_data)
    expect(subject.all.size).to eq(initial_size - 1)
  end

  it ".filter(attr, value, operator) returns an array matching criteria" do
    subject.filter("type", $type).each do |order|
      expect(order.type).to eq($type)
    end
    subject.filter("currency", $currency).each do |order|
      expect(order.currency).to eq($currency)
    end
    subject.filter("price", $price, :<).each do |order|
      expect(order.price).to be < BigDecimal.new($price)
    end
  end

end
