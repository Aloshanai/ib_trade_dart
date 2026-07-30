/// Represents a real-time market data tick update received via WebSocket or REST polling.
class MarketDataTick {
  /// Contract ID of the instrument.
  final int conid;

  /// Field identifier code or field name (e.g. '31' for Last, '84' for Bid, '86' for Ask).
  final String field;

  /// The tick value (price, volume, size, etc.).
  final dynamic value;

  /// Optional timestamp of the tick update.
  final DateTime timestamp;

  /// Creates a [MarketDataTick] instance.
  MarketDataTick({
    required this.conid,
    required this.field,
    required this.value,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Parses a [MarketDataTick] from a JSON map (typically from WS `smd+`).
  factory MarketDataTick.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return MarketDataTick(
      conid: parseInt(json['conid'] ??
          json['con_id'] ??
          json['smd'] ??
          json['topic']?.toString().replaceAll('smd+', '')),
      field: json['_field']?.toString() ??
          json['field']?.toString() ??
          json['code']?.toString() ??
          'unknown',
      value: json['value'] ?? json['_val'],
      timestamp: json['time'] != null
          ? DateTime.tryParse(json['time'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'conid': conid,
      'field': field,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MarketDataTick(conid: $conid, field: $field, value: $value)';
  }
}

/// Represents a full market data snapshot for a specific contract.
class MarketDataSnapshot {
  /// Contract ID of the instrument.
  final int conid;

  /// Symbol if available.
  final String? symbol;

  /// Current bid price.
  final double? bid;

  /// Current ask price.
  final double? ask;

  /// Last traded price.
  final double? last;

  /// High price of the day.
  final double? high;

  /// Low price of the day.
  final double? low;

  /// Previous close price.
  final double? close;

  /// Cumulative volume.
  final double? volume;

  /// All raw fields returned by IBKR `/iserver/marketdata/snapshot`.
  final Map<String, dynamic> rawFields;

  /// Creates a [MarketDataSnapshot] instance.
  const MarketDataSnapshot({
    required this.conid,
    this.symbol,
    this.bid,
    this.ask,
    this.last,
    this.high,
    this.low,
    this.close,
    this.volume,
    this.rawFields = const {},
  });

  /// Parses a [MarketDataSnapshot] from a JSON snapshot response map.
  factory MarketDataSnapshot.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      final str = val
          .toString()
          .replaceAll('C', '')
          .replaceAll('H', '')
          .replaceAll('L', '')
          .trim();
      return double.tryParse(str);
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return MarketDataSnapshot(
      conid: parseInt(json['conid'] ?? json['con_id'] ?? json['55']),
      symbol: json['55']?.toString() ?? json['symbol']?.toString(),
      bid: parseDouble(json['84'] ?? json['bid']),
      ask: parseDouble(json['86'] ?? json['ask']),
      last: parseDouble(json['31'] ?? json['last']),
      high: parseDouble(json['70'] ?? json['high']),
      low: parseDouble(json['71'] ?? json['low']),
      close: parseDouble(json['72'] ?? json['close']),
      volume: parseDouble(json['77'] ?? json['volume']),
      rawFields: json,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'conid': conid,
      if (symbol != null) 'symbol': symbol,
      if (bid != null) 'bid': bid,
      if (ask != null) 'ask': ask,
      if (last != null) 'last': last,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      'rawFields': rawFields,
    };
  }

  @override
  String toString() {
    return 'MarketDataSnapshot(conid: $conid, symbol: $symbol, last: $last, bid: $bid, ask: $ask, vol: $volume)';
  }
}
