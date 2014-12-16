require 'net/https'
require 'uri'
require 'json'
require 'yaml'

class Excoin::API
  begin
    config = YAML::load_file(File.expand_path('~/.excoin/config.yml', __FILE__))
  rescue
    config = ''
  end
  API_VERSION = config["api_version"]
  API_KEY = config["api_key"]
  API_SECRET = config["api_secret"]
  API_REPLAY_STRATEGY = config["api_replay_strategy"]
  NONCE_MULTIPLIER = config["nonce_multiplier"].to_i
  EXPIRE_INTERVAL = config["expire_interval"].to_i
  EXCOIN_API_BASE_URL = "https://api.exco.in/v#{API_VERSION}/"
  ACCOUNT_INACCESSIBLE_ERROR = "Account inaccessible, valid API key not provided."
  NO_REPLAY_STRATEGY = "Account inaccessible, valid replay strategy not provided."
  NO_REPLAY_STRATEGY_PARAM = "Account inaccessible, valid replay strategy paramter not provided."
  CONNECTION_REFUSED = "Connection refused."

  def initialize(api_key = nil, api_secret = nil, replay_strategy = nil, strategy_parameter = nil)
    @api_key = api_key
    @api_key ||= API_KEY if API_KEY =~ /\A[\w|-]{42,}/
    @api_secret = api_secret
    @api_secret ||= API_SECRET if API_SECRET =~ /\A[\w|-]{42,}/
    @account_accessible = !(@api_key.nil? or @api_secret.nil?)

    @api_replay_strategy = replay_strategy
    @api_replay_strategy ||= API_REPLAY_STRATEGY
    @api_replay_strategy_parameter = strategy_parameter
    @api_replay_strategy_parameter ||= ((EXPIRE_INTERVAL if @api_replay_strategy == "expire") or (NONCE_MULTIPLIER if @api_replay_strategy == "nonce"))
  end

  ## Exchange API

  def multiple_exchange_summary(currency = nil)
    unless currency
      self.get("summary")
    else
      self.get("summary/#{currency}")
    end
  end

  def exchange_summary(currency, commodity)
    self.get("exchange/#{currency}/#{commodity}/summary")
  end

  def exchange_recent_trades(currency, commodity, limit_type = "count", limit = 100)
    if limit_type == "count"
      self.get("exchange/#{currency}/#{commodity}/trades/#{limit}")
    elsif limit_type == "timestamp"
      self.get("exchange/#{currency}/#{commodity}/trades/timestamp/#{limit}")
    end
  end

  def exchange_open_orders(currency, commodity, type_or_count = nil)
    if type_or_count
      type = type_or_count.upcase if (type_or_count.class == String and (type_or_count.upcase == "BID" or type_or_count.upcase == "ASK"))
      count = type_or_count.to_s unless type
    end
    self.get("exchange/#{currency}/#{commodity}/orders#{ '/type/' + type if type }#{'/' + count if count}")
  end

  def exchange_candlestick_chart_data(currency, commodity, duration = nil)
    self.get("exchange/#{currency}/#{commodity}/chart/candlestick#{ '/' +  duration if duration }")
  end

  def exchange_order_depth_chart_data(currency, commodity)
    self.get("exchange/#{currency}/#{commodity}/chart/orderdepth")
  end

  ## Account API

  def account_summary
    if @account_accessible
      self.get("account/summary")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_withdraw(currency, address, amount)
    if @account_accessible
      self.get("account/withdraw/#{currency}/#{address}/#{amount}")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_generate_deposit_address(coin)
    if @account_accessible
      self.get("account/#{coin}/generate_address")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_trades(count = 100)
    if @account_accessible
      self.get("account/trades/#{count}")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_open_orders(currency = nil, commodity = nil, type = nil)
    if @account_accessible
      self.get("account/orders#{'/' + currency if currency}#{'/' + commodity if commodity}#{'/' + type if type }")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_issue_order(currency, commodity, type, amount, price)
    if @account_accessible
      self.get("account/orders/issue/#{currency}/#{commodity}/#{type}/#{amount}/#{price}")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_view_order(order_id)
    if @account_accessible
      self.get("account/order/#{order_id}")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  def account_cancel_order(order_id)
    if @account_accessible
      self.get("account/order/#{order_id}/cancel")
    else
      return{:error => ACCOUNT_INACCESSIBLE_ERROR}
    end
  end

  ## Reserves API

  def excoin_wallets_summary(coin = nil)
    unless coin
      self.get("wallets/summary")
    else
      self.get("wallet/#{coin}")
    end
  end

  def excoin_wallet_reserves(coin)
    self.get("wallet/#{coin}/reserves")
  end


  protected

    def get(relative_url)
      if @api_replay_strategy.nil?
        return{:error => NO_REPLAY_STRATEGY}
      elsif @api_replay_strategy_parameter.nil?
        return{:error => NO_REPLAY_STRATEGY_PARAM}
      end
      if @api_replay_strategy == "nonce"
        uri = URI.parse(EXCOIN_API_BASE_URL + relative_url)
        http = Net::HTTP.new(uri.host, 443)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        nonce = (Time.now.to_f * @api_replay_strategy_parameter).to_i
        message = nonce.to_s + uri.to_s
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @api_secret, message)
        request.initialize_http_header({"api-key" => @api_key})
        request.add_field("api-signature", signature)
        request.add_field("api-nonce", nonce)
      elsif @api_replay_strategy == "expire"
        expire = Time.now.utc.to_i + @api_replay_strategy_parameter
        uri = URI.parse(EXCOIN_API_BASE_URL + relative_url + "?expire=" + expire.to_s)
        http = Net::HTTP.new(uri.host, 443)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        message = uri.to_s
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @api_secret, message)
        request.add_field("api-key", @api_key)
        request.add_field("api-signature", signature)
      end

      begin
        response = http.request(request)
      rescue
        return{:error => CONNECTION_REFUSED}
      end

      begin
        response_body = JSON.parse(response.body)
      rescue
        response_body = response.message
      end

      if response.code == "200"
        return response_body
      elsif response.code == "401"
        error = response_body['error']
        return {:status => response.code, :error => error}
      elsif response.code == "400"
        error = response_body['error']
        return {:status => response.code, :error => error}
      else
        return {:status => response.code, :error => response_body}
      end
    end

end
