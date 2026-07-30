/// Parameters and filters for scanner queries.
class ScannerParams {
  /// List of supported instruments (e.g. 'STK', 'STOCK.US').
  final List<dynamic> instrumentList;

  /// Location tree for scanner regions/exchanges.
  final List<dynamic> locationTree;

  /// Available scanner filter parameters.
  final List<dynamic> filterList;

  /// Creates a [ScannerParams] instance.
  const ScannerParams({
    required this.instrumentList,
    required this.locationTree,
    required this.filterList,
  });

  /// Parses [ScannerParams] from JSON.
  factory ScannerParams.fromJson(Map<String, dynamic> json) {
    return ScannerParams(
      instrumentList:
          (json['instrument_list'] ?? json['instrumentList']) is List
              ? List.from(json['instrument_list'] ?? json['instrumentList'])
              : [],
      locationTree: (json['location_tree'] ?? json['locationTree']) is List
          ? List.from(json['location_tree'] ?? json['locationTree'])
          : [],
      filterList: (json['filter_list'] ?? json['filterList']) is List
          ? List.from(json['filter_list'] ?? json['filterList'])
          : [],
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'instrument_list': instrumentList,
      'location_tree': locationTree,
      'filter_list': filterList,
    };
  }
}

/// Request parameters for running a market scanner search.
class ScannerRequest {
  /// Target instrument (e.g., 'STK').
  final String instrument;

  /// Scanner type code (e.g., 'TOP_PERC_GAIN', 'MOST_ACTIVE').
  final String type;

  /// Scanner location code (e.g., 'STK.US.MAJOR').
  final String location;

  /// Optional list of field filter constraints.
  final List<Map<String, dynamic>>? filter;

  /// Creates a [ScannerRequest] instance.
  const ScannerRequest({
    required this.instrument,
    required this.type,
    required this.location,
    this.filter,
  });

  /// Converts this request to JSON format expected by `/iserver/scanner/run`.
  Map<String, dynamic> toJson() {
    return {
      'instrument': instrument,
      'type': type,
      'location': location,
      if (filter != null) 'filter': filter,
    };
  }
}

/// A single search result entry returned from running a scanner.
class ScannerResult {
  /// Contract ID of the instrument.
  final int conid;

  /// Ticker symbol of the instrument.
  final String symbol;

  /// Company or security name.
  final String? companyName;

  /// Scanner ranking position (1-indexed).
  final int rank;

  /// Current market price if available.
  final double? price;

  /// Price change or percentage change if available.
  final double? change;

  /// Trading volume if available.
  final double? volume;

  /// Raw result dictionary from IBKR.
  final Map<String, dynamic> raw;

  /// Creates a [ScannerResult] instance.
  const ScannerResult({
    required this.conid,
    required this.symbol,
    this.companyName,
    required this.rank,
    this.price,
    this.change,
    this.volume,
    this.raw = const {},
  });

  /// Parses a [ScannerResult] from a JSON map.
  factory ScannerResult.fromJson(Map<String, dynamic> json, [int index = 0]) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return ScannerResult(
      conid: parseInt(json['conid'] ?? json['con_id']),
      symbol: json['symbol']?.toString() ??
          json['ticker']?.toString() ??
          json['contract_description']?.toString() ??
          '',
      companyName:
          json['companyName']?.toString() ?? json['company_name']?.toString(),
      rank: parseInt(json['rank'] ?? (index + 1)),
      price: parseDouble(json['price'] ?? json['price_last']),
      change: parseDouble(json['change'] ?? json['change_percent']),
      volume: parseDouble(json['volume']),
      raw: json,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'conid': conid,
      'symbol': symbol,
      if (companyName != null) 'companyName': companyName,
      'rank': rank,
      if (price != null) 'price': price,
      if (change != null) 'change': change,
      if (volume != null) 'volume': volume,
      'raw': raw,
    };
  }

  @override
  String toString() {
    return 'ScannerResult(rank: $rank, conid: $conid, symbol: $symbol, price: $price)';
  }
}
