# Skill: Add or Extend Transport Channel

Use this skill when implementing a new transport channel or adding features (e.g., authentication, keepalive, buffer parsing) to existing TCP or WebSocket layers.

## 1. Architectural Alignment
- **Target Location:** `lib/src/transport/`
- **Dependencies Allowed:** Core Protocol Layer (`lib/src/core/`, `lib/src/models/`).
- **Dependencies Forbidden:** Scanner, Market Data, Trading, and Flutter Helpers. Under no circumstances should transport classes import or reference classes in these higher layers.

## 2. Implementation Steps

### Step 2.1: Define Interface
If not already defined, ensure all transport channels implement a unified base connection interface, facilitating switching between TCP and WebSocket clients.
```dart
abstract class IbTransport {
  Stream<List<int>> get inputStream;
  Sink<List<int>> get outputSink;
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
}
```

### Step 2.2: Implement Channel Logic
Implement the specific transport mechanism (e.g. TCP socket or Web Socket) adhering to:
- Proper exception handling and auto-reconnect logic.
- Non-blocking asynchronous event loop handling.
- Event stream exposure.

### Step 2.3: Integrate Logging
Use a decoupled logging/callback system so that transport-level warnings do not hard-depend on specific UI logging frameworks.

## 3. Verification & Testing
Create mock tests in `test/transport/` to verify:
- Connection timeout handling.
- Message framing and buffer chunks assembly.
- Correct protocol header transmission.
