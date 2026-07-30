import 'dart:convert';
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

  /// Subscribes to real-time market data for the given [conids] via WebSocket.
  void subscribeMarketData(List<int> conids, {List<String>? fields}) {
    final ws = _wsManager;
    if (ws == null) {
      throw StateError(
          'IbWebSocketManager is required for WebSocket market data subscriptions.');
    }
    ws.subscribeMarketData(conids, fields: fields);
  }

  /// Unsubscribes from real-time market data for the given [conids].
  void unsubscribeMarketData(List<int> conids) {
    final ws = _wsManager;
    if (ws == null) {
      throw StateError(
          'IbWebSocketManager is required for WebSocket market data subscriptions.');
    }
    ws.unsubscribeMarketData(conids);
  }
}
