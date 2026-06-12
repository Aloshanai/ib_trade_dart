# Base Setup & Protocol Validation Skill

This skill verifies the alignment of the workspace layout and initializes the base configuration for any protocol development.

## 1. Pre-requisites & Rules Check
Before modifying any files:
- Inspect `.cursorrules`, `.clinerules`, or `.antigravityrules`.
- Ensure you have read and understood the layered architecture.
- Identify the target layer of the current task.

## 2. Directory Validation
Check that files belong to the correct directories based on the architectural layout:
- **Core Protocol:** `lib/src/core/` and `lib/src/models/`
- **Transport Layer:** `lib/src/transport/` (TCP/WebSocket)
- **Market Data:** `lib/src/market_data/`
- **Scanner:** `lib/src/scanner/`
- **Trading:** `lib/src/orders/`
- **Flutter Helpers:** `lib/src/flutter/`

## 3. Package Dependencies Setup
Ensure standard Dart dependency patterns are followed in `pubspec.yaml`:
- Do not import `package:flutter` or Flutter plugins in Core/Transport/Scanner/Market Data/Trading layers.
- Only imports from standard Dart library or non-UI packages (e.g. `web_socket_channel`, `xml`) are permitted in non-helper layers.
- Flutter helpers layer is the only location allowed to import Flutter packages.

## 4. Verification Check
Run Dart code analysis to ensure no lint warnings:
```bash
flutter analyze
```
Ensure all tests pass:
```bash
flutter test
```
