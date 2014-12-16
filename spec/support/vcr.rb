require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassette_library'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { :record => :once }
  c.configure_rspec_metadata!

  c.register_request_matcher :uri_without_timestamp do |request_1, request_2|
    uri1, uri2 = request_1.uri, request_2.uri
    timestamp_suffix = %r(\?expire=\d+\z)
    if uri1.match(timestamp_suffix)
      r1_without_id = uri1.gsub(timestamp_suffix, "")
      r2_without_id = uri2.gsub(timestamp_suffix, "")
      uri1.match(timestamp_suffix) && uri2.match(timestamp_suffix) && r1_without_id == r2_without_id
    else
      uri1 == uri2
    end
  end
end
