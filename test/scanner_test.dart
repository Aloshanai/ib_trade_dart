import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ScannerService', () {
    test('getScannerParams returns ScannerParams', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/iserver/scanner/params')) {
          return http.Response(
            '{"instrument_list": ["STK"], "location_tree": ["STK.US.MAJOR"], "filter_list": []}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = IbTradeClient(
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: CookieClient(mockClient),
      );

      final service = ScannerService(client);
      final params = await service.getScannerParams();
      expect(params.instrumentList, contains('STK'));
    });

    test('runScanner posts query and parses results', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/iserver/scanner/run')) {
          return http.Response(
            '''
            [
              {"conid": 265598, "symbol": "AAPL", "rank": 1, "price": 155.0},
              {"conid": 3691937, "symbol": "AMZN", "rank": 2, "price": 135.0}
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

      final service = ScannerService(client);
      final results = await service.runScanner(
        const ScannerRequest(instrument: 'STK', type: 'TOP_PERC_GAIN', location: 'STK.US.MAJOR'),
      );

      expect(results.length, equals(2));
      expect(results[0].symbol, equals('AAPL'));
      expect(results[0].rank, equals(1));
      expect(results[1].symbol, equals('AMZN'));
    });
  });
}
