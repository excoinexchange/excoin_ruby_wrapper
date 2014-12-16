require 'spec_helper'

describe Excoin::Market::Exchange, vcr: { cassette_name: "multi_exchange_summ", match_requests_on: [:method, :uri_without_timestamp] } do
  subject {Excoin.market.exchange($currency + $commodity)}

  it "is a complete Excoin::Market::Exchange object" do
    expect(subject.name).to be_a(String)
    expect(subject.currency).to be_a(String)
    expect(subject.commodity).to be_a(String)
    expect(subject.last_price).to be_a(BigDecimal)
    expect(subject.daily_high).to be_a(BigDecimal)
    expect(subject.daily_low).to be_a(BigDecimal)
    expect(subject.daily_volume).to be_a(BigDecimal)
    expect(subject.top_bid).to be_a(BigDecimal)
    expect(subject.lowest_ask).to be_a(BigDecimal)
    expect(subject.spread).to be_a(BigDecimal)
    expect(subject.orders).to be_an(Excoin::Market::Exchange::Orders)
    expect(subject.trades).to be_an(Excoin::Market::Exchange::Trades)
  end

  context "with sufficient funds for order", vcr: { cassette_name: "account_issue_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: true } do
    it "issue_order(type, amount, price) checks wallet balance and creates order" do
      VCR.use_cassette("account_summary", match_requests_on: [:method, :uri_without_timestamp]) do
        if Excoin.account.wallet(subject.currency).available_balance >= BigDecimal.new($amount)
          id = subject.issue_order($type, $amount, $price)
          expect(Excoin.account.order(id)).to be_truthy
        end
      end
    end
  end

  context "insufficient funds" do
    it "issue_order returns 'insufficient funds' error", vcr: { cassette_name: "account_issue_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: true } do
       expect(subject.issue_order($type, 10000, 100)).to eq("Insufficient funds for this order (#{$currency})")
    end
  end

end
