/// Side of the order (BUY or SELL).
enum OrderSide {
  buy('BUY'),
  sell('SELL');

  final String value;
  const OrderSide(this.value);

  static OrderSide fromString(String val) {
    return OrderSide.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => OrderSide.buy,
    );
  }
}

/// Type of order (MKT, LMT, STP, STP_LMT).
enum OrderType {
  market('MKT'),
  limit('LMT'),
  stop('STP'),
  stopLimit('STP_LMT');

  final String value;
  const OrderType(this.value);

  static OrderType fromString(String val) {
    return OrderType.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => OrderType.market,
    );
  }
}

/// Time in Force for order execution.
enum TimeInForce {
  day('DAY'),
  gtc('GTC'),
  ioc('IOC');

  final String value;
  const TimeInForce(this.value);

  static TimeInForce fromString(String val) {
    return TimeInForce.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => TimeInForce.day,
    );
  }
}

/// Represents an order submission request.
class OrderRequest {
  /// The account ID to place the order for.
  final String acctId;

  /// Contract ID of the target instrument.
  final int conid;

  /// Order type (MKT, LMT, etc.).
  final OrderType orderType;

  /// Order side (BUY or SELL).
  final OrderSide side;

  /// Quantity to buy or sell.
  final double quantity;

  /// Limit price (required for LMT / STP_LMT orders).
  final double? price;

  /// Stop price (required for STP / STP_LMT orders).
  final double? auxPrice;

  /// Time in force (DAY, GTC, IOC).
  final TimeInForce tif;

  /// Whether the order can trigger/fill outside regular trading hours.
  final bool outsideRth;

  /// Optional exchange destination.
  final String? listingExchange;

  /// Security type (defaults to STK).
  final String secType;

  /// Creates a new [OrderRequest].
  const OrderRequest({
    required this.acctId,
    required this.conid,
    required this.orderType,
    required this.side,
    required this.quantity,
    this.price,
    this.auxPrice,
    this.tif = TimeInForce.day,
    this.outsideRth = false,
    this.listingExchange,
    this.secType = 'STK',
  });

  /// Converts this request into an IBKR Client Portal order payload.
  Map<String, dynamic> toJson() {
    return {
      'acctId': acctId,
      'conid': conid,
      'orderType': orderType.value,
      'side': side.value,
      'quantity': quantity,
      if (price != null) 'price': price,
      if (auxPrice != null) 'auxPrice': auxPrice,
      'tif': tif.value,
      'outsideRTH': outsideRth,
      if (listingExchange != null) 'listingExchange': listingExchange,
      'secType': secType,
    };
  }
}

/// Represents the status and details of an order returned by IBKR.
class OrderStatus {
  /// Unique IBKR order ID.
  final String orderId;

  /// Account ID associated with the order.
  final String? acctId;

  /// Current order status string (e.g. 'Submitted', 'Filled', 'Cancelled').
  final String status;

  /// Total quantity submitted.
  final double totalQuantity;

  /// Quantity filled so far.
  final double filledQuantity;

  /// Quantity remaining to be filled.
  final double remainingQuantity;

  /// Average fill price.
  final double avgFillPrice;

  /// Contract ID of the instrument.
  final int? conid;

  /// Symbol of the instrument.
  final String? symbol;

  /// Side of the order.
  final OrderSide? side;

  /// Order type.
  final OrderType? orderType;

  /// Limit price if applicable.
  final double? price;

  /// Time of submission/update.
  final String? time;

  /// Creates an [OrderStatus] instance.
  const OrderStatus({
    required this.orderId,
    this.acctId,
    required this.status,
    required this.totalQuantity,
    required this.filledQuantity,
    required this.remainingQuantity,
    required this.avgFillPrice,
    this.conid,
    this.symbol,
    this.side,
    this.orderType,
    this.price,
    this.time,
  });

  /// Parses an [OrderStatus] from JSON.
  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    return OrderStatus(
      orderId: json['orderId']?.toString() ??
          json['order_id']?.toString() ??
          json['id']?.toString() ??
          '',
      acctId: json['acctId']?.toString() ?? json['account']?.toString(),
      status: json['status']?.toString() ??
          json['orderStatus']?.toString() ??
          'Unknown',
      totalQuantity: parseDouble(
          json['totalQuantity'] ?? json['size'] ?? json['quantity']),
      filledQuantity: parseDouble(
          json['filledQuantity'] ?? json['filledSize'] ?? json['filled']),
      remainingQuantity: parseDouble(json['remainingQuantity'] ??
          json['remainingSize'] ??
          json['remaining']),
      avgFillPrice: parseDouble(
          json['avgFillPrice'] ?? json['avgPrice'] ?? json['price']),
      conid: parseInt(json['conid']),
      symbol: json['symbol']?.toString() ?? json['ticker']?.toString(),
      side: json['side'] != null
          ? OrderSide.fromString(json['side'].toString())
          : null,
      orderType: json['orderType'] != null
          ? OrderType.fromString(json['orderType'].toString())
          : null,
      price: json['price'] != null ? parseDouble(json['price']) : null,
      time: json['time']?.toString() ?? json['lastUpdateTime']?.toString(),
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      if (acctId != null) 'acctId': acctId,
      'status': status,
      'totalQuantity': totalQuantity,
      'filledQuantity': filledQuantity,
      'remainingQuantity': remainingQuantity,
      'avgFillPrice': avgFillPrice,
      if (conid != null) 'conid': conid,
      if (symbol != null) 'symbol': symbol,
      if (side != null) 'side': side!.value,
      if (orderType != null) 'orderType': orderType!.value,
      if (price != null) 'price': price,
      if (time != null) 'time': time,
    };
  }

  @override
  String toString() {
    return 'OrderStatus(orderId: $orderId, status: $status, filled: $filledQuantity/$totalQuantity, avgFillPrice: $avgFillPrice)';
  }
}
