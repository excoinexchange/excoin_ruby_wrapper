require 'spec_helper'

describe Excoin::Market::Exchange::OrderDepthChart, vcr: { cassette_name: "exchange_order_depth_chart_data", match_requests_on: [:method, :uri_without_timestamp] } do
  subject{Excoin::Market::Exchange::OrderDepthChart.new($currency + $commodity)}

  it "is a complete Excoin::Market::Exchange::OrderDepthChart object" do
    expect(subject).to be_an(Excoin::Market::Exchange::OrderDepthChart)
    expect(subject.currency).to be_a(String)
    expect(subject.commodity).to be_a(String)
    expect(subject.bid_orders).to be_an(Array)
    expect(subject.ask_orders).to be_an(Array)
  end

  it "has complete Excoin::Market::Exchange::OrderDepthChart::DataPoint objects" do
    expect(subject.bid_orders.first.type).to be_a(String)
    expect(subject.bid_orders.first.currency_amount).to be_a(String)
    expect(subject.bid_orders.first.price).to be_a(BigDecimal)
  end

end
