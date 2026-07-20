import 'dart:async';
import 'dart:convert';
import 'package:ib_trade_core/ib_trade_core.dart';
import '../models/market_data_models.dart';
import '../models/order.dart';
import '../models/position.dart';

/// Manages real-time WebSocket communication with the IBKR Gateway.
///
/// Features typed broadcast streams for market data ticks, order status updates,
/// and account summary updates.
class IbWebSocketManager {
  final IbWebSocketConnection _connection;

  final StreamController<MarketDataTick> _marketDataController =
      StreamController<MarketDataTick>.broadcast();
  final StreamController<OrderStatus> _orderStatusController =
      StreamController<OrderStatus>.broadcast();
  final StreamController<AccountSummary> _accountSummaryController =
      StreamController<AccountSummary>.broadcast();

  StreamSubscription? _messageSubscription;

  /// Creates an [IbWebSocketManager].
  ///
  /// If [_connection] is omitted, creates a default connection using [config].
  IbWebSocketManager({
    GatewayConfig? config,
    IbWebSocketConnection? connection,
    CookieClient? cookieClient,
  }) : _connection = connection ??
            IbWebSocketConnection(
              (config ?? GatewayConfig.fromEnvironment()).baseWsUri,
              cookieClient: cookieClient,
              heartbeatInterval: Duration(
                seconds: (config ?? GatewayConfig.fromEnvironment()).tickleIntervalSeconds,
              ),
            ) {
    _listenToMessages();
  }

  /// Stream of connection state updates.
  Stream<IbWebSocketState> get stateChanges => _connection.stateChanges;

  /// Current connection state.
  IbWebSocketState get state => _connection.state;

  /// Stream of incoming real-time market data tick updates.
  Stream<MarketDataTick> get marketDataStream => _marketDataController.stream;

  /// Stream of incoming order status updates.
  Stream<OrderStatus> get orderStatusStream => _orderStatusController.stream;

  /// Stream of incoming account summary updates.
  Stream<AccountSummary> get accountSummaryStream => _accountSummaryController.stream;

  /// Connects to the gateway WebSocket endpoint.
  Future<void> connect() async {
    await _connection.connect();
  }

  /// Disconnects the WebSocket connection.
  Future<void> disconnect() async {
    await _connection.disconnect();
  }

  void _listenToMessages() {
    _messageSubscription = _connection.messages.listen((dynamic rawMessage) {
      if (rawMessage is! String) return;
      _parseAndDispatch(rawMessage);
    });
  }

  void _parseAndDispatch(String rawMessage) {
    // Handle plain heartbeat response 'nt' or 'system' messages
    if (rawMessage == 'nt' || rawMessage.startsWith('system')) return;

    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is Map<String, dynamic>) {
        final topic = decoded['topic']?.toString() ?? '';

        if (topic.startsWith('smd+') || decoded.containsKey('smd') || decoded.containsKey('_field')) {
          _marketDataController.add(MarketDataTick.fromJson(decoded));
        } else if (topic.startsWith('sor') || decoded.containsKey('orderId') || decoded.containsKey('orderStatus')) {
          _orderStatusController.add(OrderStatus.fromJson(decoded));
        } else if (topic.startsWith('sact') || decoded.containsKey('netLiquidation') || decoded.containsKey('netliquidation')) {
          _accountSummaryController.add(AccountSummary.fromJson(decoded));
        } else if (decoded.containsKey('conid') && decoded.containsKey('field')) {
          _marketDataController.add(MarketDataTick.fromJson(decoded));
        }
      }
    } catch (_) {
      // Non-JSON message or unparseable frame ignored
    }
  }

  /// Subscribes to market data for the given [conids].
  ///
  /// Sends `smd+{conid}+{"fields":[...]}` over the WebSocket connection.
  void subscribeMarketData(List<int> conids, {List<String>? fields}) {
    for (final conid in conids) {
      final payload = fields != null && fields.isNotEmpty
          ? jsonEncode({'fields': fields})
          : '{}';
      _connection.send('smd+$conid+$payload');
    }
  }

  /// Unsubscribes from market data for the given [conids].
  void unsubscribeMarketData(List<int> conids) {
    for (final conid in conids) {
      _connection.send('umd+$conid+{}');
    }
  }

  /// Subscribes to real-time order status updates (`sor+{}`).
  void subscribeOrders() {
    _connection.send('sor+{}');
  }

  /// Unsubscribes from order status updates (`uor+{}`).
  void unsubscribeOrders() {
    _connection.send('uor+{}');
  }

  /// Subscribes to account summary updates (`sact+{}`).
  void subscribeAccount() {
    _connection.send('sact+{}');
  }

  /// Unsubscribes from account summary updates (`uact+{}`).
  void unsubscribeAccount() {
    _connection.send('uact+{}');
  }

  /// Closes internal stream controllers and underlying socket connection.
  Future<void> close() async {
    await _messageSubscription?.cancel();
    await _connection.close();
    await _marketDataController.close();
    await _orderStatusController.close();
    await _accountSummaryController.close();
  }
}
