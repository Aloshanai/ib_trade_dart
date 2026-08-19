# Getting Started with your IBKR Trading Project

This guide provides instructions on how to set up, configure, and structure a trading project using the **Interactive Brokers (IBKR) Trading SDK for Dart & Flutter** (`ib_trade_dart`).

---

## 1. Gateway Setup (Mandatory First Step)

Interactive Brokers does not allow your application to connect directly to their servers. Instead, you must run the official **Client Portal API Gateway** locally on your machine, which acts as a bridge.

1. **Install Java 8 or higher:**
   - The Gateway is a Java application. Download Java (Adoptium Temurin is recommended).
2. **Download & Configure the Gateway:**
   - Follow the detailed steps in [SETUP.md: Section 4](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/SETUP.md#L57-L101) to download the Client Portal API Gateway zip, extract it, and modify `root/conf.yaml` if needed.
3. **Run the Gateway:**
   - In your command line, run:
     - **Windows:** `bin\run.bat root\conf.yaml`
     - **macOS/Linux:** `bin/run.sh root/conf.yaml`
4. **Authenticate in the Browser:**
   - Navigate to `https://localhost:5000` in your web browser.
   - Log in using your **Paper Trading Account** credentials.
   - Once the page indicates **"Client login succeeds"**, keep the command line window running. Your SDK is now authorized to send requests.

---

## 2. Project Initialization & Dependencies

To consume this SDK in your own Dart or Flutter application, add the package to your `pubspec.yaml` dependencies.

### Option A: Local Dependency (Recommended during Development)
If you are developing your project on the same computer as this SDK, link it via path:
```yaml
dependencies:
  flutter:
    sdk: flutter
  ib_trade_dart:
    path: ../ib_trade_dart # Path to the SDK repository root
```

### Option B: Remote GitHub Dependency
If your repository is hosted on GitHub, you can reference it directly:
```yaml
dependencies:
  ib_trade_dart:
    git:
      url: https://github.com/Aloshanai/ib_trade_dart.git
      ref: main
```

Run `dart pub get` or `flutter pub get` after modifying `pubspec.yaml`.

---

## 3. Recommended Project Architecture

For a robust trading application (automated bot or GUI dashboard), decouple your application layers:

```text
my_trading_app/
├── lib/
│   ├── services/
│   │   ├── ib_connection.dart       # Handles SDK client initialization & authentication checks
│   │   ├── market_data_service.dart  # Fetches tickers, price snapshots, and scanners
│   │   └── execution_service.dart    # Manages order creation and execution
│   ├── models/                       # Custom models (TradeSignals, Positions, Portfolio)
│   ├── logic/                        # State management (Blocs, Riverpod, or ChangeNotifiers)
│   │   ├── trading_bloc.dart         # Processes signals and triggers orders
│   │   └── live_ticker_bloc.dart     # Manages live price updates
│   └── main.dart
```

---

## 4. Core Implementation Snippets

### A. Initializing the SDK Client
Instantiate `GatewayConfig` and pass it to `IbTradeClient` (refer to [configure.md](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/configure.md) for more customization options).

```dart
// lib/services/ib_connection.dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

class IbConnection {
  late final GatewayConfig config;
  late final IbTradeClient client;

  void initialize() {
    config = GatewayConfig(
      host: 'localhost',
      port: 5000,                  // Default IBKR gateway port
      useSsl: true,
      bypassSslVerification: true, // Required for self-signed gateway certificate
    );
    client = IbTradeClient(config: config);
  }

  Future<bool> checkConnection() async {
    final status = await client.checkAuthStatus();
    return status.authenticated && status.connected;
  }
}
```

### B. Real-Time Price Streaming (WebSocket)
Do not poll the REST API for live prices. Instead, use `IbWebSocketManager` to listen to ticker ticks (refer to [ib_websocket_manager.dart](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/lib/src/websocket/ib_websocket_manager.dart)).

```dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

void startStreaming(GatewayConfig config, List<int> conids) async {
  final wsManager = IbWebSocketManager(config: config);
  
  // Connect to the WebSocket
  await wsManager.connect();

  // Listen for real-time market data tick events
  wsManager.marketDataStream.listen((MarketDataTick tick) {
    print('Conid: ${tick.conid} | Bid: \$${tick.bid} | Ask: \$${tick.ask} | Last: \$${tick.last}');
  });

  // Subscribe to your target contract IDs (e.g., 265598 for AAPL)
  wsManager.subscribeMarketData(conids);
}
```

### C. Placing Orders
Place orders using the `OrderService` (refer to [ib_trade_dart_example.dart](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/example/ib_trade_dart_example.dart#L51-L66) for reference).

```dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

Future<void> placeLimitBuyOrder({
  required IbTradeClient client,
  required String accountId,
  required int conid,
  required double limitPrice,
  required double quantity,
}) async {
  final orderService = OrderService(client);

  final orderReq = OrderRequest(
    acctId: accountId,
    conid: conid,
    orderType: OrderType.limit,
    side: OrderSide.buy,
    quantity: quantity,
    price: limitPrice,
    tif: TimeInForce.day,
  );

  try {
    final statuses = await orderService.placeOrder(accountId, orderReq);
    for (final status in statuses) {
      print('Placed Order ID: ${status.orderId} | Status: ${status.status}');
    }
  } catch (e) {
    print('Error placing order: $e');
  }
}
```

---

## 5. Development Best Practices & Rules of Thumb

> [!IMPORTANT]
> **Use Paper Trading Exclusively during Development:**
> Do not use a live production account. Double check that the gateway console reports connection to paper servers.

> [!WARNING]
> **Keep-Alive (Session Expiry):**
> The IBKR gateway expires sessions after long periods of inactivity. Ensure you run your app using `GatewayConfig` with the keep-alive interval enabled (default is `tickleIntervalSeconds: 45`) to automatically keep the session active.

> [!CAUTION]
> **Respect IBKR Pacing Rules:**
> IBKR rate-limits rest endpoints. If you request snapshots (`MarketDataService.getSnapshot`) or scanners too rapidly, they will temporarily block requests. Rely on WebSockets for real-time price updates.
