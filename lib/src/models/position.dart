/// Represents an account position in a specific instrument.
class Position {
  /// Account ID holding the position.
  final String acctId;

  /// Contract ID of the instrument.
  final int conid;

  /// Description or symbol of the contract.
  final String contractDescription;

  /// Total position size (positive for long, negative for short).
  final double position;

  /// Current market price.
  final double mktPrice;

  /// Total market value of the position.
  final double mktValue;

  /// Average cost basis per share/unit.
  final double avgCost;

  /// Unrealized Profit & Loss.
  final double unrealizedPnl;

  /// Realized Profit & Loss.
  final double realizedPnl;

  /// Currency denomination.
  final String currency;

  /// Creates a [Position] instance.
  const Position({
    required this.acctId,
    required this.conid,
    required this.contractDescription,
    required this.position,
    required this.mktPrice,
    required this.mktValue,
    required this.avgCost,
    required this.unrealizedPnl,
    required this.realizedPnl,
    required this.currency,
  });

  /// Factory constructor to parse a [Position] from JSON.
  factory Position.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return Position(
      acctId: json['acctId']?.toString() ?? json['account']?.toString() ?? '',
      conid: parseInt(json['conid']),
      contractDescription: json['contractDescription']?.toString() ??
          json['ticker']?.toString() ??
          json['symbol']?.toString() ??
          '',
      position: parseDouble(json['position'] ?? json['pos']),
      mktPrice: parseDouble(json['mktPrice'] ?? json['mktprice']),
      mktValue: parseDouble(json['mktValue'] ?? json['mktvalue']),
      avgCost: parseDouble(json['avgCost'] ?? json['avgcost']),
      unrealizedPnl:
          parseDouble(json['unrealizedPnl'] ?? json['unrealizedpnl']),
      realizedPnl: parseDouble(json['realizedPnl'] ?? json['realizedpnl']),
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  /// Converts this [Position] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'acctId': acctId,
      'conid': conid,
      'contractDescription': contractDescription,
      'position': position,
      'mktPrice': mktPrice,
      'mktValue': mktValue,
      'avgCost': avgCost,
      'unrealizedPnl': unrealizedPnl,
      'realizedPnl': realizedPnl,
      'currency': currency,
    };
  }

  @override
  String toString() {
    return 'Position(acctId: $acctId, conid: $conid, desc: $contractDescription, pos: $position, mktValue: $mktValue, unrealizedPnl: $unrealizedPnl)';
  }
}

/// Represents high-level summary balances for an IBKR trading account.
class AccountSummary {
  /// Account ID.
  final String acctId;

  /// Net Liquidation Value.
  final double netLiquidation;

  /// Total Cash Value.
  final double totalCashValue;

  /// Settled Cash.
  final double settledCash;

  /// Accrued Cash.
  final double accruedCash;

  /// Total Buying Power.
  final double buyingPower;

  /// Equity with Loan Value.
  final double equityWithLoanValue;

  /// Unrealized PnL across all holdings.
  final double unrealizedPnl;

  /// Realized PnL across all trades.
  final double realizedPnl;

  /// Creates an [AccountSummary] instance.
  const AccountSummary({
    required this.acctId,
    required this.netLiquidation,
    required this.totalCashValue,
    required this.settledCash,
    required this.accruedCash,
    required this.buyingPower,
    required this.equityWithLoanValue,
    required this.unrealizedPnl,
    required this.realizedPnl,
  });

  /// Factory constructor to parse [AccountSummary] from JSON.
  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return AccountSummary(
      acctId: json['acctId']?.toString() ?? json['account']?.toString() ?? '',
      netLiquidation:
          parseDouble(json['netLiquidation'] ?? json['netliquidation']),
      totalCashValue:
          parseDouble(json['totalCashValue'] ?? json['totalcashvalue']),
      settledCash: parseDouble(json['settledCash'] ?? json['settledcash']),
      accruedCash: parseDouble(json['accruedCash'] ?? json['accruedcash']),
      buyingPower: parseDouble(json['buyingPower'] ?? json['buyingpower']),
      equityWithLoanValue: parseDouble(
          json['equityWithLoanValue'] ?? json['equitywithloanvalue']),
      unrealizedPnl:
          parseDouble(json['unrealizedPnl'] ?? json['unrealizedpnl']),
      realizedPnl: parseDouble(json['realizedPnl'] ?? json['realizedpnl']),
    );
  }

  /// Converts this [AccountSummary] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'acctId': acctId,
      'netLiquidation': netLiquidation,
      'totalCashValue': totalCashValue,
      'settledCash': settledCash,
      'accruedCash': accruedCash,
      'buyingPower': buyingPower,
      'equityWithLoanValue': equityWithLoanValue,
      'unrealizedPnl': unrealizedPnl,
      'realizedPnl': realizedPnl,
    };
  }

  @override
  String toString() {
    return 'AccountSummary(acctId: $acctId, netLiquidation: $netLiquidation, totalCash: $totalCashValue, buyingPower: $buyingPower)';
  }
}
