import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IbTradeClient Facade & Domain Services Integration', () {
    late IbTradeClient client;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.endsWith('/iserver/auth/status')) {
          return http.Response(
            '{"authenticated": true, "connected": true, "competing": false, "fail": ""}',
            200,
          );
        }
        if (path.endsWith('/portfolio/accounts')) {
          return http.Response(
            '[{"id": "U1234567", "accountVan": "U1234567", "accountTitle": "Main Account", "type": "INDIVIDUAL", "currency": "USD", "clearingStatus": "O"}]',
            200,
          );
        }
        if (path.endsWith('/portfolio/U1234567/summary')) {
          return http.Response(
            '{"netLiquidation": 50000.0, "totalCashValue": 20000.0, "buyingPower": 80000.0, "grossPositionValue": 30000.0, "initMarginReq": 5000.0, "maintMarginReq": 4000.0}',
            200,
          );
        }
        if (path.endsWith('/iserver/secdef/search')) {
          return http.Response(
            '[{"conid": 265598, "symbol": "AAPL", "companyHeader": "Apple Inc.", "companyName": "Apple Inc.", "description": "AAPL", "secType": "STK", "currency": "USD"}]',
            200,
          );
        }
        if (path.endsWith('/iserver/marketdata/snapshot')) {
          return http.Response(
            '[{"conid": 265598, "31": "150.25", "84": "150.20", "86": "150.30", "7295": "1000000"}]',
            200,
          );
        }
        if (path.endsWith('/hmds/scanner/params')) {
          return http.Response(
            '{"instrument_list": ["STK"], "location_tree": ["STK.US.MAJOR"], "filter_list": []}',
            200,
          );
        }
        if (path.endsWith('/iserver/account/alerts')) {
          return http.Response(
            '[{"alertId": 101, "alertName": "AAPL Target", "account": "U1234567", "alertActive": true}]',
            200,
          );
        }
        if (path.endsWith('/one/user')) {
          return http.Response(
            '{"userId": 9999, "userName": "testuser", "email": "user@example.com", "isPaper": true, "features": {}}',
            200,
          );
        }

        return http.Response('{"error": "Not Found"}', 404);
      });

      final cookieClient = CookieClient(mockClient);
      final config =
          GatewayConfig(host: 'localhost', port: 5000, useSsl: false);
      final coreClient =
          IbTradeCoreClient(config: config, httpClient: cookieClient);

      client = IbTradeClient(
        config: config,
        httpClient: HttpClient(bypassSslVerification: true),
        cookieClient: cookieClient,
        coreClient: coreClient,
      );
    });

    test('SessionService retrieves auth status', () async {
      final status = await client.session.getAuthStatus();
      expect(status.authenticated, isTrue);
      expect(status.connected, isTrue);
    });

    test('AccountService retrieves accounts and summary', () async {
      final accounts = await client.account.getAccounts();
      expect(accounts.length, equals(1));
      expect(accounts.first.accountId, equals('U1234567'));

      final summary = await client.account.getAccountSummary('U1234567');
      expect(summary.netLiquidation, equals(50000.0));
      expect(summary.buyingPower, equals(80000.0));
    });

    test('ContractService searches contracts', () async {
      final results = await client.contracts.searchContracts('AAPL');
      expect(results.length, equals(1));
      expect(results.first.conid, equals(265598));
      expect(results.first.symbol, equals('AAPL'));
    });

    test('MarketDataService retrieves market snapshots', () async {
      final snapshots = await client.marketData.getMarketDataSnapshot([265598]);
      expect(snapshots.length, equals(1));
      expect(snapshots.first.conid, equals(265598));
      expect(snapshots.first.lastPrice, equals(150.25));
    });

    test('ScannerService retrieves scanner params', () async {
      final params = await client.scanner.getScannerParams();
      expect(params.instrumentList, contains('STK'));
    });

    test('AlertService retrieves active alerts', () async {
      final alerts = await client.alerts.getAlerts('U1234567');
      expect(alerts.length, equals(1));
      expect(alerts.first.alertId, equals(101));
      expect(alerts.first.alertName, equals('AAPL Target'));
    });

    test('UserService retrieves authenticated user info', () async {
      final user = await client.user.getUserInfo();
      expect(user.userId, equals(9999));
      expect(user.userName, equals('testuser'));
      expect(user.isPaper, isTrue);
    });

    test('ExecutionHistory model serialization and deserialization', () {
      final jsonMap = {
        'executionId': 'exec123',
        'orderId': 'ord456',
        'conid': 265598,
        'symbol': 'AAPL',
        'side': 'BUY',
        'price': 150.25,
        'quantity': 100.0,
        'time': '2026-08-19T10:00:00Z',
        'account': 'U1234567',
        'commission': 1.0,
        'exchange': 'NASDAQ',
      };

      final exec = Execution.fromJson(jsonMap);
      expect(exec.executionId, equals('exec123'));
      expect(exec.symbol, equals('AAPL'));
      expect(exec.price, equals(150.25));

      final history = ExecutionHistory(executions: [exec]);
      expect(history.executions.length, equals(1));
      expect(history.toJson()['executions'], isList);
    });
  });
}
