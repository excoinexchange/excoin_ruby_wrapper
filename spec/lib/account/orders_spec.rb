require 'spec_helper'

describe Excoin::Account::Orders do
  subject {Excoin.account.orders}

  it "is an Excoin::Account::Orders object" do
    expect(subject).to be_an(Excoin::Account::Orders)
  end

  it ".all returns array of complete Order objects" do
    expect(subject.all).to be_an(Array)
    subject.all.each do |order|
      expect(order).to be_an(Excoin::Account::Order)
      expect(order.currency).to be_a(String)
      expect(order.commodity).to be_a(String)
      expect(order.type).to be_a(String)
      expect(order.id).to be_a(String)
      expect(order.timestamp).to be_a(Time)
      expect(order.price).to be_a(BigDecimal)
      expect(order.currency_amount).to be_a(BigDecimal)
      expect(order.commodity_amount).to be_a(BigDecimal)
      expect(order.status).to be_a(String)
    end
  end

  it ".add(order) adds Order object to Orders" do
    initial_count = subject.count
    order = Excoin::Account::Order.new($order_data)
    subject.add(order)
    expect(subject.count).to eq(initial_count + 1)
    expect(subject.all).to include{|new_order| new_order.id == $order_data['id']}
  end

  it ".delete(order_data) removes Order matching order_data from Orders" do
    subject.delete($order_data)
    expect(subject.all).to_not include{|order| order.id == $order_data['id']}
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
