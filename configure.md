# Configuration Guide

This guide explains how to configure the **Interactive Brokers Trading SDK for Dart & Flutter**. 

Configuration is managed via the `GatewayConfig` class, which handles the parameters needed to connect to the Interactive Brokers Client Portal Gateway (both HTTP/HTTPS and WebSocket/WSS protocols).

---

## GatewayConfig Parameters

The `GatewayConfig` constructor accepts the following parameters:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `host` | `String` | `'localhost'` | The hostname or IP address where the Gateway is running. |
| `port` | `int` | `5000` | The port number the Gateway is listening on (specified in `conf.yaml`). |
| `useSsl` | `bool` | `true` | Whether to use SSL (`https` and `wss`) for requests. |
| `bypassSslVerification` | `bool` | `false` | Bypasses self-signed SSL verification. Set to `true` for local development since the default local gateway cert is self-signed. |
| `tickleIntervalSeconds` | `int` | `45` | How often (in seconds) the SDK sends a keep-alive tickle ping to prevent session timeouts. |
| `connectionTimeoutSeconds` | `int` | `10` | Timeout in seconds for Gateway connection requests. |

---

## 1. Programmatic Configuration

You can instantiate `GatewayConfig` programmatically and pass it directly to `IbTradeClient` or `IbWebSocketManager`:

```dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

void main() {
  final config = GatewayConfig(
    host: 'localhost',
    port: 5000,
    useSsl: true,
    bypassSslVerification: true, // Required for local self-signed certificates
    tickleIntervalSeconds: 30,    // Ping every 30 seconds
    connectionTimeoutSeconds: 15,
  );

  // Initialize REST client
  final client = IbTradeClient(config: config);

  // Initialize WebSocket manager
  final wsManager = IbWebSocketManager(config: config);
}
```

---

## 2. Configuration via Environment Variables

The SDK supports zero-config initialization by loading settings directly from the environment using `GatewayConfig.fromEnvironment()`. If you do not supply a `config` object when initializing `IbTradeClient` or `IbWebSocketManager`, it will default to loading from these environment variables.

### Supported Environment Variables (Case-Insensitive)

- `IBKR_GATEWAY_HOST` (Default: `'localhost'`)
- `IBKR_GATEWAY_PORT` (Default: `5000`)
- `IBKR_GATEWAY_USE_SSL` (Default: `'true'`)
- `IBKR_GATEWAY_BYPASS_SSL` (Default: `'false'`)
- `IBKR_GATEWAY_TICKLE_INTERVAL` (Default: `45`)
- `IBKR_GATEWAY_TIMEOUT` (Default: `10`)

### Example Usage

#### In PowerShell (Windows):
```powershell
$env:IBKR_GATEWAY_HOST="127.0.0.1"
$env:IBKR_GATEWAY_PORT="5000"
$env:IBKR_GATEWAY_BYPASS_SSL="true"

dart run example/ib_trade_dart_example.dart
```

#### In Bash (macOS/Linux):
```bash
export IBKR_GATEWAY_HOST="127.0.0.1"
export IBKR_GATEWAY_PORT="5000"
export IBKR_GATEWAY_BYPASS_SSL="true"

dart run example/ib_trade_dart_example.dart
```

---

## 3. Configuration from a Map

If your configuration is stored in a JSON file, YAML file, or a configuration database, you can load it using `GatewayConfig.fromMap()`:

```dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

void main() {
  final Map<String, dynamic> myConfigJson = {
    'host': '192.168.1.100',
    'port': 5000,
    'useSsl': true,
    'bypassSslVerification': true,
    'tickleIntervalSeconds': 60,
  };

  final config = GatewayConfig.fromMap(myConfigJson);
  final client = IbTradeClient(config: config);
}
```

---

## Gateway Setup Tips

> [!IMPORTANT]
> To configure the physical port or check SSL setups of the Interactive Brokers Client Portal Gateway itself:
> 
> 1. Navigate to the extracted gateway folder.
> 2. Open `root/conf.yaml`.
> 3. Verify or update the `listenPort` field:
>    ```yaml
>    # root/conf.yaml
>    listenPort: 5000
>    ```
> 4. For detailed gateway setup and user login flow details, refer to [SETUP.md](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/SETUP.md).
