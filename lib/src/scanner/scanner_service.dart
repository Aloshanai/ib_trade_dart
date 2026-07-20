import 'dart:convert';
import '../client/ib_trade_client.dart';
import '../models/scanner_models.dart';

/// Service handling market scanner parameter retrieval and execution of scanner queries.
class ScannerService {
  final IbTradeClient _client;

  /// Creates a [ScannerService] with the given [_client].
  ScannerService(this._client);

  /// Fetches available scanner parameters, instruments, location trees, and filter lists.
  ///
  /// Endpoint: `GET /iserver/scanner/params`
  Future<ScannerParams> getScannerParams() async {
    final response = await _client.get('iserver/scanner/params');

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ScannerParams.fromJson(jsonMap);
    } else {
      throw Exception('Failed to fetch scanner parameters: HTTP ${response.statusCode}');
    }
  }

  /// Runs a market scanner query with the parameters specified in [request].
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
        final List<ScannerResult> results = [];
        for (int i = 0; i < jsonResponse.length; i++) {
          final item = jsonResponse[i];
          if (item is Map<String, dynamic>) {
            results.add(ScannerResult.fromJson(item, i));
          }
        }
        return results;
      }
      return [];
    } else {
      throw Exception('Failed to run market scanner: HTTP ${response.statusCode}');
    }
  }
}
