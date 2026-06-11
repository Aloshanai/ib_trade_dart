# ib_trade_dart

A Dart library for interacting with Interactive Brokers API (Client, WebSocket, Orders, Scanner, and Models).

## Features

- **Client**: Connect and send requests to the Interactive Brokers API.
- **WebSocket**: Stream live market data, account updates, and execution reports.
- **Models**: Strongly-typed Dart models for Contracts, Orders, Positions, Executions, and more.
- **Scanner**: Real-time scanners for stock, option, and future contracts.
- **Orders**: Create, validate, submit, and manage orders.

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ib_trade_dart:
    path: ../ib_trade_dart # or version when published
```

## Usage

```dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

void main() {
  print('ib_trade_dart initialized.');
}
```

