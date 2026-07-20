/// Represents a financial instrument contract in Interactive Brokers.
class Contract {
  /// Unique IBKR contract identifier.
  final int conid;

  /// Ticker symbol of the instrument (e.g., 'AAPL').
  final String symbol;

  /// Security type (e.g., 'STK', 'OPT', 'FUT', 'CASH', 'IND').
  final String secType;

  /// Primary exchange or destination exchange (e.g., 'NASDAQ', 'SMART').
  final String? exchange;

  /// Currency denomination (e.g., 'USD', 'EUR').
  final String? currency;

  /// Full company or security name.
  final String? companyName;

  /// Creates a new [Contract] instance.
  const Contract({
    required this.conid,
    required this.symbol,
    required this.secType,
    this.exchange,
    this.currency,
    this.companyName,
  });

  /// Factory constructor to parse a [Contract] from a JSON map.
  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      conid: json['conid'] is int
          ? json['conid'] as int
          : int.tryParse(json['conid']?.toString() ?? '') ?? 0,
      symbol: json['symbol']?.toString() ?? json['ticker']?.toString() ?? '',
      secType: json['secType']?.toString() ?? json['assetClass']?.toString() ?? 'STK',
      exchange: json['exchange']?.toString() ?? json['listingExchange']?.toString(),
      currency: json['currency']?.toString(),
      companyName: json['companyName']?.toString(),
    );
  }

  /// Converts this [Contract] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'conid': conid,
      'symbol': symbol,
      'secType': secType,
      if (exchange != null) 'exchange': exchange,
      if (currency != null) 'currency': currency,
      if (companyName != null) 'companyName': companyName,
    };
  }

  @override
  String toString() {
    return 'Contract(conid: $conid, symbol: $symbol, secType: $secType, exchange: $exchange, currency: $currency)';
  }
}
