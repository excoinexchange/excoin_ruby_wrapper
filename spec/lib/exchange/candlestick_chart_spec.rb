require 'spec_helper'

describe Excoin::Market::Exchange::CandlestickChart, vcr: { cassette_name: "exchange_candlestick_chart_data", match_requests_on: [:method, :uri_without_timestamp] } do
  subject{Excoin::Market::Exchange::CandlestickChart.new($currency + $commodity)}

  it "is a complete Excoin::Market::Exchange::CandlestickChart object" do
    expect(subject).to be_an(Excoin::Market::Exchange::CandlestickChart)
    expect(subject.currency).to be_a(String)
    expect(subject.commodity).to be_a(String)
    expect(subject.datapoints).to be_a(Array)
  end

  it "has complete Excoin::Market::Exchange::CandlestickChart::DataPoint objects" do
    expect(subject.datapoints.first.timestamp).to be_a(Time)
    expect(subject.datapoints.first.open).to be_a(BigDecimal)
    expect(subject.datapoints.first.close).to be_a(BigDecimal)
    expect(subject.datapoints.first.high).to be_a(BigDecimal)
    expect(subject.datapoints.first.low).to be_a(BigDecimal)
    expect(subject.datapoints.first.commodity_volume).to be_a(BigDecimal)
    expect(subject.datapoints.first.currency_volume).to be_a(BigDecimal)
  end

end
