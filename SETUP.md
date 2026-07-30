# SDK Setup Guide

Welcome to the **Interactive Brokers Trading SDK for Dart & Flutter**! This guide is designed to help you set up your development environment and get the SDK running from scratch, even if you have no prior experience with the project.

---

## 1. Prerequisites

Before we start, you need to install a few tools on your system.

### A. Dart SDK
This SDK is written in Dart. You need Dart version `3.0.0` or higher.
- [Download and Install Dart](https://dart.dev/get-dart)
- Verify installation by running:
  ```bash
  dart --version
  ```

### B. Flutter SDK (Optional)
If you plan to use this SDK to build a Flutter application:
- [Install Flutter](https://docs.flutter.dev/get-started/install)
- Verify installation by running:
  ```bash
  flutter --version
  ```

### C. Java Runtime Environment (JRE)
The Interactive Brokers Client Portal Gateway is a Java-based application. You need Java 8 or higher (Java 11 or 17 is recommended).
- [Download Java (Adoptium Temurin)](https://adoptium.net/)
- Verify installation by running:
  ```bash
  java -version
  ```

## 2. Setting Up the Repository

Clone the `ib_trade_dart` repository to your local machine:

```bash
git clone https://github.com/Aloshanai/ib_trade_dart.git
cd ib_trade_dart
```

---

## 3. Fetching Dependencies

Fetch the package dependencies, including `ib_trade_core` from pub.dev:

```bash
dart pub get
```
   ```

---

## 4. Setting Up the IBKR Client Portal Gateway

To connect to Interactive Brokers, you must download, configure, and run their official Client Portal API Gateway locally.

### A. Download the Gateway
1. Go to the [Official IBKR Client Portal API Documentation / Quickstart](https://interactivebrokers.github.io/cpwebapi/).
2. Locate the **API Gateway** download section on the page or download the ZIP directly:
   - [Direct Download Link: clientportal.gw.zip](https://download2.interactivebrokers.com/portal/clientportal.gw.zip)
3. Extract the downloaded ZIP to a folder on your computer (e.g., `C:\ibkr_gateway\clientportal.gw`).

### B. Configure the Gateway
Inside the unzipped gateway directory:
1. Locate the file `root/conf.yaml`.
2. By default, the gateway listens on port `5000`. You can verify or change this by opening `conf.yaml` and checking the `listenPort` property:
   ```yaml
   # root/conf.yaml
   listenPort: 5000
   ```

### C. Run the Gateway
> [!IMPORTANT]
> The gateway must be run via the command line. Keeping this window open is required to keep the gateway running.
1. Open your terminal or command prompt.
2. Navigate to your unzipped gateway directory:
   ```bash
   cd C:\ibkr_gateway\clientportal.gw
   ```
3. Run the startup script:
   - **Windows (PowerShell/Command Prompt):**
     ```powershell
     bin\run.bat root\conf.yaml
     ```
   - **macOS / Linux:**
     ```bash
     chmod +x bin/run.sh
     bin/run.sh root/conf.yaml
     ```

### D. Log In and Authenticate (Crucial Step)
The API Gateway does not authenticate programmatically. You must log in manually via the browser:
1. Open your browser and navigate to: `https://localhost:5000` (ignore self-signed SSL warnings if they appear).
2. Log in with your **Interactive Brokers username and password** (Paper trading or Live).
3. Complete any two-factor authentication (2FA) required on your phone.
4. Once you see a webpage showing **"Client login succeeds"** or **"Authenticated"**, your local gateway is authenticated and ready!

---

## 5. Running the Example Code

The SDK comes with a preconfigured example to test your setup. Make sure your gateway is running and authenticated (Section 4).

1. Navigate to the `ib_trade_dart` root folder.
2. Open [example/ib_trade_dart_example.dart](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/example/ib_trade_dart_example.dart) to inspect or modify the code.
3. Run the example:
   ```bash
   dart run example/ib_trade_dart_example.dart
   ```
4. If successful, you will see output in your console fetching market data snapshots and placing a mock order.

---

## 6. Running Tests

To verify that the SDK functions correctly and everything is configured properly, run the test suite:

1. Ensure you are in the `ib_trade_dart` directory.
2. Run the tests using the Dart test runner:
   ```bash
   dart test
   ```

All tests are located in the [test/](file:///c:/Users/Admin/Documents/GitHub/ib_trade_dart/test) folder.

---

## 7. Configuration Details for Code

When instantiating the client in your own code, configure it as follows:

```dart
import 'package:ib_trade_dart/ib_trade_dart.dart';

final config = GatewayConfig(
  host: 'localhost',
  port: 5000,
  useSsl: true,
  // MUST be true unless you have loaded a valid SSL cert into your local gateway.
  bypassSslVerification: true, 
);

final client = IbTradeClient(config: config);
```

---

## 8. Common Troubleshooting

### 1. SSL Certificate Errors
- **Problem:** `HandshakeException: Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED)`
- **Solution:** Make sure you set `bypassSslVerification: true` when instantiating `GatewayConfig`. The local gateway uses self-signed SSL certificates by default.

### 2. Authentication Failures (Not Authenticated / 401 Unauthorized)
- **Problem:** The SDK throws errors checking auth status or fails to fetch market data.
- **Solution:** You must go to `https://localhost:5000` in your web browser and log in. The SDK cannot perform the initial login/2FA on your behalf.

### 3. Connection Refused
- **Problem:** `SocketException: Connection refused (OS Error: Connection refused, errno = 111)`
- **Solution:** Check that the IBKR Gateway terminal/command prompt window is running and hasn't closed, and that the port in `GatewayConfig` matches `listenPort` in your `conf.yaml` (default is 5000).

### 4. Dependency Resolution Error
- **Problem:** Dart cannot find `ib_trade_core`.
- **Solution:** Run `dart pub get` to fetch the dependency from pub.dev. Make sure your internet connection is active and that your `pubspec.yaml` contains `ib_trade_core` under `dependencies`.

---

## Helpful Links
- [Official IBKR Client Portal API Guide](https://interactivebrokers.github.io/cpwebapi/)
- [Dart Packages Directory](https://pub.dev/)
- [Interactive Brokers Portal Quickstart](https://interactivebrokers.github.io/cpwebapi/Quickstart.html)
