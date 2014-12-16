# ExcoinWrapper

A wrapper for accessing the exchange and account API at exco.in.

## Installation

To install with Bundler, add this line to your application's Gemfile:

    gem 'excoin_wrapper', git: "https://github.com/excoinexchange/excoin_wrapper_ruby.git"

And then execute:

    $ bundle

Or build and it install it yourself:

    $ git clone https://github.com/excoinexchange/excoin_wrapper_ruby.git
    $ cd excoin_wrapper_ruby
    $ gem build excoin.gemspec
    $ gem install ./excoin-0.0.1.gem

Finally, `require 'excoin'` in your application.

## Usage

#### Basic Functions

Start by connecting to the API and setting your API key, secret, replay attack prevention strategy ("expire" or "nonce"), and replay attack prevention strategy parameter (expire time in seconds for expire, multiplier for nonce) : `Excoin.api(api_key, secret, replay_strategy, strategy_parameter)`. If you set your API authentication information in `~/.excoin/config.yml` or you aren't using a key (for example, if you're only pulling down general exchange data), you can skip this step and go straight to:

`Excoin.account` (API authentication required) to initialize a new Excoin::Account object and populate its data
`Excoin.market` to initialize a new Excoin::Market object with all associated exchanges and data
`Excoin.exchange(exchange_name)` to initialize a new Excoin::Market::Exchange object with data from a single trading pair

#### Account Functions

    a = Excoin.account
    => #<Excoin::Account:0x007f0000000000>

##### Useful attributes and functions of the account class:
__class Excoin::Account__

    attr_reader :name, :active_wallet_count, :active_wallets,
                :inactive_wallet_count, :inactive_wallets,
                :deposit_count, :withdrawal_count, :withdrawals,
                :orders, :trades

    order(order_id)             # returns account order object with specified id
    wallets                     # returns a hash of all wallets
    wallet(currency)            # returns the hash of the specified wallet
    deposits(currency = nil)    # returns a hash of all deposits, or all deposits
                                # matching currency

    add_deposit(deposit_data)   # adds new Deposit object to account.deposits
    unconfirmed_deposits        # returns a hash of all unconfirmed deposits
    withdrawals(currency = nil) # returns a hash of all withdrawals, or all
                                # withdrawals matching currency

    unconfirmed_withdrawals     # returns a hash of all unconfirmed withdrawals
    add_withdrawal(withdrawal_data)
                                # adds new Withdrawal object to account.withdrawals

    update                      # updates account summary, orders, and trades
    populate_account_summary    # updates account summary data only

__class Excoin::Account::Deposit__

    attr_reader :timestamp, :currency, :id, :address,
                :amount, :confirmations, :confirmed

__class Excoin::Account::Withdrawal__

    attr_reader :id, :timestamp, :currency, :address, :amount, :confirmed

__class Excoin::Account::Orders < Array__
An array of open account orders, grouped by exchange

    add(order)                  # adds Account::Order object to Account::Orders object
    delete(order_data)          # deletes Order object matching order_data

    all                         # returns all orders in one dimensional array
    filter(attr, value, operator = :==)
                                # returns an array of all orders matching criteria

    count(attr = nil, value = nil, operator = :==)
                                # returns count of all orders matching criteria

    update(exchange_name = nil) # updates all account orders or orders
                                # on specified exchange

    refresh                     # clears orders array and updates

    >> a.orders.filter("currency_amount",0.01,:<)
    => # returns all orders with currency_amount less than 0.01

__class Excoin::Account::Order__

    attr_reader :currency, :commodity, :type, :id, :timestamp, :price,
                :commodity_amount, :currency_amount, :status

    exchange                    # returns associated Exchange object
    refresh                     # refreshes single order data
    cancel                      # cancels order

__class Excoin::Account::Trades < Array__
An array of the most recent trades on account (count default 100, up to 750)

    buys                        # all buy trades in Trades object
    sells                       # all sell trades in Trades object
    highest(type = nil)         # highest trade, or highest trade of *type*
    lowest(type = nil)          # lowest trade, or lowest trade of *type*
    update(count = nil)         # update Trades object with most recent trades
    add(trade_data)             # add new Trade object to Trades array
    trim(n)                     # removes the n oldest trades from the Trades object

__class Excoin::Account::Trade__

    attr_reader :timestamp, :currency, :commodity, :type, :price, :sent,
                :received, :fee, :net_received

    exchange                    # returns associated Exchange object

__class Excoin::Account::Wallet__

    attr_reader :status, :currency, :deposit_address, :confirmed_balance,
                :available_balance, :order_balance,
                :pending_deposit_balance, :pending_withdrawal_balance,
                :deposits, :withdrawals

    update(wallet_data)              # updates wallet with wallet_data
    unconfirmed_deposits             # returns hash of all unconfirmed deposits
    unconfirmed_withdrawals          # returns hash of all unconfirmed withdrawls
    add_deposit(deposit_data)        # adds new Deposit object to deposits hash
    add_withdrawal(withdrawal_data)  # adds new Withdrawal to withdrawals hash
    withdraw(address, amount)        # initiates withdrawal and adds it to
                                     # Wallet object

#### Exchange Functions

    >> e = Excoin.market.exchange("BTCBLK")
    >> e = Excoin.exchange("BTCBLK")
    => #<Excoin::Market::Exchange:0x007f8e13a71db0 @name="BTCBLK" ...>

##### Useful attributes and functions of the exchange class:

__class Excoin::Market < Array__
An array of all Exchange objects on the Excoin market

    exchanges(currency)        # an array of all exchanges denomiated in currency
    exchange(exchange_name)    # selects Exchange object
    update                     # updates all exchanges in Market array
    update_orders              # updates orders on all exchanges
    refresh_all_data           # clears and reinitializes all exchanges


__class Excoin::Market::Exchange__

    attr_reader :name, :currency, :commodity, :last_price, :daily_high,
                :daily_low, :daily_volume, :top_bid, :lowest_ask, :orders,
                :trades, :spread

    update                     # update exchange summary, orders, and trades
    update_summary             # update exchange summary only
    issue_order(type, amount, price)
                               # place order of type "bid" or "ask"
                               # amount in units of currency for bids, and
                               # units of commodity for asks, price in units
                               # of currency

    >> e.issue_order("bid", "0.25", "0.0003")
    => # places bid order of 0.25 BTC for BLK at a price of 0.0003 BTC/BLK
       # and adds order to e.orders and a.orders

    >> e.issue_order("ask", 100, "0.00035")
    => # places ask order selling 100 BLK at a price of 0.00035 BTC/BLK
       # and adds order to e.orders and a.orders

__class Excoin::Market::Exchange::Orders__

    attr_reader :bids, :asks, :all, :orders

    add(order)                 # adds Exchange::Order object to Exchange::Orders object
    remove(order_data)         # removes an order matching order_data from Orders object
    update(type = nil)         # update all orders on exchange, or all orders
                               # of type
    filter(attr, value, operator = :==)
                             # returns an array of all orders matching criteria
    count(attr, value, operator = :==)
                             # returns the count of all orders matching criteria

__class Excoin::Market::Exchange::Order__

    attr_reader :currency, :commodity, :type, :price,
                :commodity_amount, :currency_amount

    exchange                  # returns associated Exchange object

__class Excoin::Market::Exchange::Trades < Array__
An array of the most recent trades on exchange (count default 100, up to 750)

    buys                        # all buy trades in Trades object
    sells                       # all sell trades in Trades object
    highest(type = nil)         # highest trade, or highest trade of *type*
    lowest(type = nil)          # lowest trade, or lowest trade of *type*
    update(limit_type = "count", limit = 100)
                                # update all trades on exchange, limited by
                                # limit_type: "count" or "timestamp"
                                # limit:
                                #   integer <= 750 for "count"
                                #   (time in UTC).to_i for "timestamp"
    add(trade_data)             # add new Trade object to Trades array
    trim(n)                     # removes the n oldest trades from the Trades object

__class Excoin::Market::Exchange::Trade__

    attr_reader :timestamp, :currency, :commodity, :type, :price,
                :commodity_amount, :currency_amount

    exchange                  # returns associated Exchange object

__class Excoin::Market::Exchange::OrderDepthChart__

    attr_reader :currency, :commodity, :bid_orders, :ask_orders

    update                    # updates all chart order data
    exchange                  # returns associated Exchange object

__class Excoin::Market::Exchange::OrderDepthChart::DataPoint__

    attr_reader :type, :currency_amount, :price

__class Excoin::Market::Exchange::CandlestickChart__

    attr_reader :currency, :commodity, :datapoints

    update                     # update datapoints
    exchange                   # returns associated Exchange object

__class Excoin::Market::Exchange::CandlestickChart::DataPoint__

    attr_reader :timestamp, :open, :close, :high, :low, :commodity_volume,
                :currency_volume

#### API Functions
These are the base methods used by the wrapper to import the Excoin API's JSON data.

__class Excoin::API__

    multiple_exchange_summary(currency = nil)
    exchange_summary(currency, commodity)
    exchange_recent_trades(currency, commodity, limit_type = "count", limit = 100)
    exchange_open_orders(currency, commodity, type_or_count = nil)
    exchange_candlestick_chart_data(currency, commodity, duration = nil)
    exchange_order_depth_chart_data(currency, commodity)

    account_summary
    account_withdraw(currency, address, amount)
    account_generate_deposit_address(coin)
    account_trades(count = 100)
    account_open_orders(currency = nil, commodity = nil, type = nil)
    account_issue_order(currency, commodity, type, amount, price)
    account_view_order(order_id)
    account_view_order(order_id)

    excoin_wallets_summary(coin = nil)
    excoin_wallet_reserves(coin)

### Troubleshooting
__Problem:__ Excoin.api.account_issue_order returns a 404.

__Solution:__ If the amount or price is very small, Ruby converts the number to scientific notation (i.e 1.809E-6). Passing the number as a string avoids this.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/excoin_wrapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
