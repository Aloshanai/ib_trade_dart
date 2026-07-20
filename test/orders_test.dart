import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OrderService', () {
    test('placeOrder submits order and returns status', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/iserver/account/U1234567/orders')) {
          return http.Response(
            '[{"orderId": "8001", "status": "Submitted", "totalQuantity": 100, "filledQuantity": 0, "remainingQuantity": 100, "avgFillPrice": 0.0}]',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = IbTradeClient(
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: CookieClient(mockClient),
      );

      final service = OrderService(client);
      final statuses = await service.placeOrder(
        'U1234567',
        const OrderRequest(
          acctId: 'U1234567',
          conid: 265598,
          orderType: OrderType.limit,
          side: OrderSide.buy,
          quantity: 100,
          price: 150.0,
        ),
      );

      expect(statuses.length, equals(1));
      expect(statuses[0].orderId, equals('8001'));
      expect(statuses[0].status, equals('Submitted'));
    });

    test('cancelOrder sends DELETE request', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'DELETE' && request.url.path.contains('/iserver/account/U1234567/order/8001')) {
          return http.Response('{"msg": "Order cancelled"}', 200);
        }
        return http.Response('Not Found', 404);
      });

      final client = IbTradeClient(
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: CookieClient(mockClient),
      );

      final service = OrderService(client);
      final success = await service.cancelOrder('U1234567', '8001');
      expect(success, isTrue);
    });

    test('getPositions parses position list', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/portfolio/U1234567/positions/0')) {
          return http.Response(
            '''
            [
              {"acctId": "U1234567", "conid": 265598, "contractDescription": "AAPL", "position": 100, "mktPrice": 150.0, "mktValue": 15000.0, "avgCost": 140.0, "unrealizedPnl": 1000.0, "realizedPnl": 0.0, "currency": "USD"}
            ]
            ''',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = IbTradeClient(
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: CookieClient(mockClient),
      );

      final service = OrderService(client);
      final positions = await service.getPositions('U1234567');
      expect(positions.length, equals(1));
      expect(positions[0].conid, equals(265598));
      expect(positions[0].contractDescription, equals('AAPL'));
    });
  });
}
