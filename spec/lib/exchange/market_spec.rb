require 'spec_helper'

describe Excoin::Market do
  subject {Excoin.market}

  it "is a complete Excoin::Market object", vcr: { cassette_name: 'multi_exchange_summ', match_requests_on: [:method, :uri_without_timestamp] } do
    expect(subject.first).to be_an(Excoin::Market::Exchange)
  end

  it "exchanges(currency) returns all exchanges with currency", vcr: { cassette_name: 'multi_exchange_summ_currency', match_requests_on: [:method, :uri_without_timestamp] } do
    expect(subject.exchanges($currency)).to be_an(Array)
    subject.exchanges($currency).each do |exchange|
      expect(exchange.currency).to eq($currency)
    end
  end

  it "exchange(exchange_name) returns matching Exchange object", vcr: { cassette_name: 'single_exchange_summary', match_requests_on: [:method, :uri_without_timestamp] } do
    exchange = subject.exchange($currency + $commodity)
    expect(exchange).to be_an(Excoin::Market::Exchange)
    expect(exchange.currency).to eq($currency)
    expect(exchange.commodity).to eq($commodity)
  end
end
