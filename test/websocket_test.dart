import 'dart:async';
import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

class MockWebSocketConnection implements IbWebSocketConnection {
  final _stateController = StreamController<IbWebSocketState>.broadcast();
  final _messageController = StreamController<dynamic>.broadcast();
  final _errorController = StreamController<dynamic>.broadcast();
  IbWebSocketState _state = IbWebSocketState.disconnected;

  final List<String> sentMessages = [];

  @override
  IbWebSocketState get state => _state;

  @override
  Stream<IbWebSocketState> get stateChanges => _stateController.stream;

  @override
  Stream<dynamic> get messages => _messageController.stream;

  @override
  Stream<dynamic> get errors => _errorController.stream;

  @override
  Future<void> connect() async {
    _state = IbWebSocketState.connected;
    _stateController.add(_state);
  }

  @override
  Future<void> disconnect() async {
    _state = IbWebSocketState.disconnected;
    _stateController.add(_state);
  }

  @override
  void send(String message) {
    sentMessages.add(message);
  }

  void injectMessage(String msg) {
    _messageController.add(msg);
  }

  @override
  Future<void> close() async {
    await disconnect();
    await _stateController.close();
    await _messageController.close();
    await _errorController.close();
  }
}

void main() {
  group('IbWebSocketManager', () {
    late MockWebSocketConnection mockConn;
    late IbWebSocketManager manager;

    setUp(() {
      mockConn = MockWebSocketConnection();
      manager = IbWebSocketManager(connection: mockConn);
    });

    tearDown(() async {
      await manager.close();
    });

    test('subscribeMarketData sends correct smd message', () async {
      manager.subscribeMarketData([265598], fields: ['31', '84']);
      expect(mockConn.sentMessages, contains('smd+265598+{"fields":["31","84"]}'));
    });

    test('parses incoming market data tick', () async {
      final tickFuture = manager.marketDataStream.first;
      mockConn.injectMessage('{"topic": "smd+265598", "conid": 265598, "_field": "31", "value": 150.25}');

      final tick = await tickFuture;
      expect(tick.conid, equals(265598));
      expect(tick.field, equals('31'));
      expect(tick.value, equals(150.25));
    });

    test('parses incoming order status update', () async {
      final orderFuture = manager.orderStatusStream.first;
      mockConn.injectMessage('{"topic": "sor", "orderId": "5001", "status": "Filled", "totalQuantity": 10, "filledQuantity": 10, "remainingQuantity": 0, "avgFillPrice": 150.0}');

      final orderStatus = await orderFuture;
      expect(orderStatus.orderId, equals('5001'));
      expect(orderStatus.status, equals('Filled'));
      expect(orderStatus.filledQuantity, equals(10.0));
    });
  });
}
