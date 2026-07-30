import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IbTradeClient', () {
    test('checkAuthStatus parses successfully', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/iserver/auth/status')) {
          return http.Response(
            '{"authenticated": true, "connected": true, "competing": false, "fail": ""}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final cookieClient = CookieClient(mockClient);
      final client = IbTradeClient(
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: cookieClient,
      );

      final authStatus = await client.checkAuthStatus();
      expect(authStatus.authenticated, isTrue);
      expect(authStatus.connected, isTrue);
    });

    test('post automatically handles challenges and retries', () async {
      int requestCount = 0;

      final mockClient = MockClient((request) async {
        requestCount++;
        if (request.url.path.contains('/iserver/reply/')) {
          return http.Response('{"confirmed": true}', 200);
        }
        if (requestCount == 1) {
          // First attempt responds with a challenge prompt
          return http.Response(
            '[{"id": "c123", "message": ["Are you sure?"]}]',
            200,
          );
        }
        // Second attempt after challenge resolved
        return http.Response(
            '[{"orderId": "999", "status": "Submitted"}]', 200);
      });

      final cookieClient = CookieClient(mockClient);
      final client = IbTradeClient(
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: cookieClient,
      );

      final response = await client
          .post('iserver/account/U123/orders', body: {'test': true});
      expect(response.statusCode, equals(200));
      expect(response.body, contains('999'));
    });
  });
}
