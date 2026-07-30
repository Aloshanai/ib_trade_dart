import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MarketDataService', () {
    test('getSnapshot retrieves and parses market data snapshot', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/iserver/marketdata/snapshot')) {
          expect(
              request.url.queryParameters['conids'], equals('265598,3691937'));
          return http.Response(
            '''
            [
              {"conid": 265598, "55": "AAPL", "31": "150.25", "84": "150.20", "86": "150.30"},
              {"conid": 3691937, "55": "AMZN", "31": "130.10", "84": "130.00", "86": "130.20"}
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

      final service = MarketDataService(client);
      final snapshots = await service.getSnapshot([265598, 3691937]);

      expect(snapshots.length, equals(2));
      expect(snapshots[0].conid, equals(265598));
      expect(snapshots[0].symbol, equals('AAPL'));
      expect(snapshots[0].last, equals(150.25));
      expect(snapshots[1].symbol, equals('AMZN'));
    });
  });
}
