import 'dart:convert';
import 'package:ib_trade_core/ib_trade_core.dart' as core;
import '../client/ib_trade_client.dart';
import '../models/scanner_models.dart';

/// Service handling market scanner parameter queries and scan executions.
class ScannerService {
  final IbTradeClient _client;

  /// Creates a [ScannerService] with the given [_client].
  ScannerService(this._client);

  /// Fetches available scanner parameters (instruments, scanner types, location trees, filter lists).
  ///
  /// Endpoint: `GET /iserver/scanner/params`
  Future<ScannerParams> getScannerParams() async {
    final response = await _client.get('iserver/scanner/params');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map<String, dynamic>) {
        return ScannerParams.fromJson(jsonResponse);
      }
      return const ScannerParams(
        instrumentList: [],
        locationTree: [],
        filterList: [],
      );
    } else {
      throw Exception(
          'Failed to fetch scanner parameters: HTTP ${response.statusCode}');
    }
  }

  /// Executes a market scan with the given [request].
  ///
  /// Endpoint: `POST /iserver/scanner/run`
  Future<List<ScannerResult>> runScanner(ScannerRequest request) async {
    final response = await _client.post(
      'iserver/scanner/run',
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .asMap()
            .entries
            .where((e) => e.value is Map<String, dynamic>)
            .map((e) =>
                ScannerResult.fromJson(e.value as Map<String, dynamic>, e.key))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to run scanner: HTTP ${response.statusCode}');
    }
  }

  /// Delegates directly to core strongly-typed scanner service.
  Future<core.ScannerResult> runCoreScanner(core.ScannerRequest request) async {
    return await _client.scanner.runScanner(request);
  }
}
