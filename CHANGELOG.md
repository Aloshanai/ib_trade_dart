## 0.1.1

- Updated core dependency to `ib_trade_core` `^0.1.1`.
- Integrated 10 core domain adaptation services into `IbTradeClient` facade (`session`, `account`, `orders`, `contracts`, `marketData`, `scanner`, `alerts`, `user`, `streaming`).
- Added support for `ExecutionHistory` and `Execution` trade execution models.
- Exposed lifecycle management (`connect()`, `disconnect()`, `dispose()`) on `IbTradeClient`.
- Re-exported core models, `IbResult<T>`, and `McpToolRegistryAdapter`.
- Added comprehensive unit testing coverage for all domain adaptation services.

## 0.1.0

- Initial release of `ib_trade_dart` SDK.
