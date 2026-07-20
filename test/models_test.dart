import 'package:ib_trade_dart/ib_trade_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Contract Model', () {
    test('Contract.fromJson & toJson', () {
      final jsonMap = {
        'conid': 265598,
        'symbol': 'AAPL',
        'secType': 'STK',
        'exchange': 'NASDAQ',
        'currency': 'USD',
        'companyName': 'Apple Inc.',
      };

      final contract = Contract.fromJson(jsonMap);
      expect(contract.conid, equals(265598));
      expect(contract.symbol, equals('AAPL'));
      expect(contract.secType, equals('STK'));
      expect(contract.exchange, equals('NASDAQ'));
      expect(contract.currency, equals('USD'));
      expect(contract.companyName, equals('Apple Inc.'));

      final jsonOut = contract.toJson();
      expect(jsonOut['conid'], equals(265598));
      expect(jsonOut['symbol'], equals('AAPL'));
    });
  });

  group('Order Models', () {
    test('OrderRequest.toJson', () {
      final req = OrderRequest(
        acctId: 'U1234567',
        conid: 265598,
        orderType: OrderType.limit,
        side: OrderSide.buy,
        quantity: 100,
        price: 150.5,
        tif: TimeInForce.gtc,
        outsideRth: true,
      );

      final jsonMap = req.toJson();
      expect(jsonMap['acctId'], equals('U1234567'));
      expect(jsonMap['conid'], equals(265598));
      expect(jsonMap['orderType'], equals('LMT'));
      expect(jsonMap['side'], equals('BUY'));
      expect(jsonMap['quantity'], equals(100));
      expect(jsonMap['price'], equals(150.5));
      expect(jsonMap['tif'], equals('GTC'));
      expect(jsonMap['outsideRTH'], isTrue);
    });

    test('OrderStatus.fromJson', () {
      final jsonMap = {
        'orderId': '10001',
        'acctId': 'U1234567',
        'status': 'Submitted',
        'totalQuantity': 100,
        'filledQuantity': 50,
        'remainingQuantity': 50,
        'avgFillPrice': 150.25,
      };

      final status = OrderStatus.fromJson(jsonMap);
      expect(status.orderId, equals('10001'));
      expect(status.acctId, equals('U1234567'));
      expect(status.status, equals('Submitted'));
      expect(status.totalQuantity, equals(100.0));
      expect(status.filledQuantity, equals(50.0));
      expect(status.remainingQuantity, equals(50.0));
      expect(status.avgFillPrice, equals(150.25));
    });
  });

  group('Position & AccountSummary Models', () {
    test('Position.fromJson', () {
      final jsonMap = {
        'acctId': 'U1234567',
        'conid': 265598,
        'contractDescription': 'AAPL',
        'position': 100.0,
        'mktPrice': 155.0,
        'mktValue': 15500.0,
        'avgCost': 145.0,
        'unrealizedPnl': 1000.0,
        'realizedPnl': 250.0,
        'currency': 'USD',
      };

      final pos = Position.fromJson(jsonMap);
      expect(pos.acctId, equals('U1234567'));
      expect(pos.conid, equals(265598));
      expect(pos.position, equals(100.0));
      expect(pos.unrealizedPnl, equals(1000.0));
    });

    test('AccountSummary.fromJson', () {
      final jsonMap = {
        'acctId': 'U1234567',
        'netLiquidation': 50000.0,
        'totalCashValue': 20000.0,
        'settledCash': 20000.0,
        'accruedCash': 0.0,
        'buyingPower': 80000.0,
        'equityWithLoanValue': 50000.0,
        'unrealizedPnl': 5000.0,
        'realizedPnl': 1200.0,
      };

      final summary = AccountSummary.fromJson(jsonMap);
      expect(summary.acctId, equals('U1234567'));
      expect(summary.netLiquidation, equals(50000.0));
      expect(summary.buyingPower, equals(80000.0));
    });
  });

  group('Scanner Models', () {
    test('ScannerParams & ScannerResult parsing', () {
      final paramsJson = {
        'instrument_list': ['STK', 'OPT'],
        'location_tree': ['STK.US.MAJOR'],
        'filter_list': ['priceAbove'],
      };
      final params = ScannerParams.fromJson(paramsJson);
      expect(params.instrumentList, contains('STK'));

      final resultJson = {
        'conid': 265598,
        'symbol': 'AAPL',
        'companyName': 'Apple Inc.',
        'rank': 1,
        'price': 150.0,
        'change': 5.2,
      };
      final result = ScannerResult.fromJson(resultJson);
      expect(result.rank, equals(1));
      expect(result.symbol, equals('AAPL'));
      expect(result.change, equals(5.2));
    });
  });

  group('Market Data Models', () {
    test('MarketDataTick & MarketDataSnapshot parsing', () {
      final tickJson = {
        'conid': 265598,
        '_field': '31',
        'value': 150.75,
      };
      final tick = MarketDataTick.fromJson(tickJson);
      expect(tick.conid, equals(265598));
      expect(tick.field, equals('31'));
      expect(tick.value, equals(150.75));

      final snapshotJson = {
        'conid': 265598,
        '55': 'AAPL',
        '84': '150.50',
        '86': '150.60',
        '31': '150.55',
        '77': '1000000',
      };
      final snapshot = MarketDataSnapshot.fromJson(snapshotJson);
      expect(snapshot.conid, equals(265598));
      expect(snapshot.symbol, equals('AAPL'));
      expect(snapshot.bid, equals(150.50));
      expect(snapshot.ask, equals(150.60));
      expect(snapshot.last, equals(150.55));
    });
  });
}
