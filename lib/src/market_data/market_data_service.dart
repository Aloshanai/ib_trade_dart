import 'dart:convert';
import 'package:ib_trade_core/ib_trade_core.dart' as core;
import '../client/ib_trade_client.dart';
import '../models/market_data_models.dart';
import '../websocket/ib_websocket_manager.dart';

/// Service handling market data snapshot queries and real-time streaming subscriptions.
class MarketDataService {
  final IbTradeClient _client;
  final IbWebSocketManager? _wsManager;

  /// Creates a [MarketDataService].
  MarketDataService(
    this._client, {
    IbWebSocketManager? wsManager,
  }) : _wsManager = wsManager;

  /// Stream of real-time market data ticks from the WebSocket manager.
  Stream<MarketDataTick> get ticksStream {
    final ws = _wsManager;
    if (ws == null) {
      throw StateError(
          'IbWebSocketManager is required to listen to ticksStream.');
    }
    return ws.marketDataStream;
  }

  /// Fetches a market data snapshot for one or more contract IDs ([conids]).
  ///
  /// Endpoint: `GET /iserver/marketdata/snapshot`
  ///
  /// Optional [fields] list specifies tick codes to retrieve (e.g. `['31', '84', '86']`).
  Future<List<MarketDataSnapshot>> getSnapshot(
    List<int> conids, {
    List<String>? fields,
  }) async {
    if (conids.isEmpty) return [];

    final queryParams = <String, String>{
      'conids': conids.join(','),
      if (fields != null && fields.isNotEmpty) 'fields': fields.join(','),
    };

    final response = await _client.get(
      'iserver/marketdata/snapshot',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .whereType<Map<String, dynamic>>()
            .map((e) => MarketDataSnapshot.fromJson(e))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        return [MarketDataSnapshot.fromJson(jsonResponse)];
      }
      return [];
    } else {
      throw Exception(
          'Failed to fetch market data snapshot: HTTP ${response.statusCode}');
    }
  }

  /// Delegates to `ib_trade_core`'s strongly-typed [core.MarketDataService].
  Future<List<core.MarketSnapshot>> getMarketDataSnapshot(
    List<int> conids, {
    List<core.MarketDataField>? fields,
  }) async {
    return await _client.marketData
        .getMarketDataSnapshot(conids, fields: fields);
  }

  /// Fetches historical OHLCV bar series.
  Future<core.HistoricalDataSeries> getHistoricalBars(
    int conid, {
    required dynamic period,
    required dynamic barSize,
    bool outsideRth = false,
    String priceType = 'TRADES',
  }) async {
    final periodEnum = period is core.BarPeriod
        ? period
        : core.BarPeriod.values.firstWhere(
            (e) => e.code == period.toString(),
            orElse: () => core.BarPeriod.oneDay,
          );
    final barSizeEnum = barSize is core.BarSize
        ? barSize
        : core.BarSize.values.firstWhere(
            (e) => e.code == barSize.toString(),
            orElse: () => core.BarSize.oneHour,
          );
    return await _client.marketData.getHistoricalBars(
      conid,
      period: periodEnum,
      barSize: barSizeEnum,
      outsideRth: outsideRth,
      priceType: priceType,
    );
  }

  /// Unsubscribes all active market data snapshots.
  Future<bool> unsubscribeAll() async {
    return await _client.marketData.unsubscribeAll();
  }

  /// Subscribes to real-time market data for the given [conids] via WebSocket.
  void subscribeMarketData(List<int> conids, {List<String>? fields}) {
    final ws = _wsManager;
    if (ws != null) {
      ws.subscribeMarketData(conids, fields: fields);
    } else {
      _client.streaming.subscribeQuotes(
        conids.first,
        fields: fields?.map((f) => core.MarketDataField.last).toList() ?? [],
      );
    }
  }

  /// Unsubscribes from real-time market data for the given [conids].
  void unsubscribeMarketData(List<int> conids) {
    final ws = _wsManager;
    if (ws != null) {
      ws.unsubscribeMarketData(conids);
    } else {
      for (final conid in conids) {
        _client.streaming.unsubscribeQuotes(conid);
      }
    }
  }
}
