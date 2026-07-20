import 'package:ib_trade_dart/ib_trade_dart.dart';

void main() async {
  print('--- Interactive Brokers Dart SDK Example ---');

  // 1. Instantiate Gateway Configuration
  final config = GatewayConfig(
    host: 'localhost',
    port: 5000,
    useSsl: true,
    bypassSslVerification: true,
  );

  // 2. Initialize High-Level SDK Client
  final client = IbTradeClient(config: config);

  try {
    // 3. Check Authentication Status
    print('Checking authentication status...');
    final authStatus = await client.checkAuthStatus();
    print('Authenticated: ${authStatus.authenticated}');
    print('Connected: ${authStatus.connected}');

    // 4. Initialize Services
    final marketDataService = MarketDataService(client);
    final scannerService = ScannerService(client);
    final orderService = OrderService(client);

    // 5. Fetch Market Data Snapshot
    print('\nFetching market data snapshot for AAPL (conid: 265598)...');
    final snapshots = await marketDataService.getSnapshot([265598]);
    for (final snapshot in snapshots) {
      print('Snapshot: ${snapshot.symbol} | Last: \$${snapshot.last} | Bid: \$${snapshot.bid} | Ask: \$${snapshot.ask}');
    }

    // 6. Run Market Scanner
    print('\nRunning top percentage gainers scanner...');
    final scannerRequest = ScannerRequest(
      instrument: 'STK',
      type: 'TOP_PERC_GAIN',
      location: 'STK.US.MAJOR',
    );
    final results = await scannerService.runScanner(scannerRequest);
    print('Found ${results.length} scanner results:');
    for (final result in results.take(5)) {
      print('  Rank #${result.rank}: ${result.symbol} (conid: ${result.conid})');
    }

    // 7. Submit a Limit Order
    print('\nSubmitting limit order for AAPL...');
    final orderReq = OrderRequest(
      acctId: 'U1234567',
      conid: 265598,
      orderType: OrderType.limit,
      side: OrderSide.buy,
      quantity: 10,
      price: 150.0,
      tif: TimeInForce.day,
    );

    final statuses = await orderService.placeOrder('U1234567', orderReq);
    for (final status in statuses) {
      print('Placed Order Status: ${status.orderId} -> ${status.status}');
    }
  } catch (e) {
    print('SDK Error: $e');
  } finally {
    client.close();
    print('\nSDK Client closed.');
  }
}
