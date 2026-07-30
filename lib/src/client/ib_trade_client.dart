import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ib_trade_core/ib_trade_core.dart';

/// The central high-level client for communicating with the IBKR Client Portal Gateway.
///
/// Wraps low-level HTTP transport, session tickling, cookie management,
/// and automated challenge resolution.
class IbTradeClient {
  /// Connection configuration settings.
  final GatewayConfig config;

  /// Underlying custom HTTP client.
  final HttpClient httpClient;

  /// Cookie management client wrapper.
  final CookieClient cookieClient;

  /// Session tickler for keeping the gateway session active.
  final SessionTickler sessionTickler;

  /// Compliance and safety challenge handler.
  final ChallengeHandler challengeHandler;

  /// Creates an instance of [IbTradeClient].
  ///
  /// If [config] is not provided, defaults to [GatewayConfig.fromEnvironment()].
  IbTradeClient({
    GatewayConfig? config,
    HttpClient? httpClient,
    CookieClient? cookieClient,
    SessionTickler? sessionTickler,
    ChallengeHandler? challengeHandler,
  })  : config = config ?? GatewayConfig.fromEnvironment(),
        httpClient = httpClient ??
            HttpClient(
                bypassSslVerification: config?.bypassSslVerification ?? false),
        cookieClient = cookieClient ??
            CookieClient(httpClient ??
                HttpClient(
                    bypassSslVerification:
                        config?.bypassSslVerification ?? false)),
        sessionTickler = sessionTickler ??
            SessionTickler(
              cookieClient ??
                  CookieClient(httpClient ??
                      HttpClient(
                          bypassSslVerification:
                              config?.bypassSslVerification ?? false)),
              (config ?? GatewayConfig.fromEnvironment()).baseHttpUri,
              interval: Duration(
                  seconds: (config ?? GatewayConfig.fromEnvironment())
                      .tickleIntervalSeconds),
            ),
        challengeHandler = challengeHandler ??
            ChallengeHandler(
              cookieClient ??
                  CookieClient(httpClient ??
                      HttpClient(
                          bypassSslVerification:
                              config?.bypassSslVerification ?? false)),
              (config ?? GatewayConfig.fromEnvironment()).baseHttpUri,
            );

  /// Checks the gateway session authentication status.
  ///
  /// Endpoint: `GET /iserver/auth/status`
  Future<AuthStatus> checkAuthStatus() async {
    final response = await get('iserver/auth/status');
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthStatus.fromJson(jsonMap);
    } else {
      throw IbException(
        'Failed to check auth status: HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Starts periodic session tickling (keep-alive).
  void startSessionTickler() {
    sessionTickler.start();
  }

  /// Stops periodic session tickling.
  void stopSessionTickler() {
    sessionTickler.stop();
  }

  /// Resolves any compliance challenges present in [responseJson] and retries execution.
  Future<http.Response> resolveChallengesAndRetry(
    dynamic responseJson,
    Future<http.Response> Function() retryAction,
  ) async {
    List<dynamic> challengesList = [];
    if (responseJson is List) {
      challengesList = responseJson;
    } else if (responseJson is Map &&
        responseJson.containsKey('id') &&
        (responseJson.containsKey('message') ||
            responseJson.containsKey('messages'))) {
      challengesList = [responseJson];
    }

    if (challengesList.isNotEmpty) {
      for (final item in challengesList) {
        if (item is Map<String, dynamic> && item.containsKey('id')) {
          final challenge = IbChallenge.fromJson(item);
          await challengeHandler.handleChallenge(challenge);
        }
      }
      // Retry the original request after confirming challenges
      return await retryAction();
    }

    return await retryAction();
  }

  /// Executes an HTTP GET request relative to [config.baseHttpUri].
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = config.baseHttpUri.resolve(endpoint).replace(
          queryParameters:
              queryParameters?.map((k, v) => MapEntry(k, v.toString())),
        );

    final reqHeaders = <String, String>{
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    final response = await cookieClient.get(uri, headers: reqHeaders);
    return response;
  }

  /// Executes an HTTP POST request relative to [config.baseHttpUri].
  ///
  /// Automatically detects and resolves safety challenges if encountered.
  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool autoHandleChallenges = true,
  }) async {
    final uri = config.baseHttpUri.resolve(endpoint);
    final reqHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    final bodyStr =
        body != null ? (body is String ? body : jsonEncode(body)) : null;

    http.Response response =
        await cookieClient.post(uri, headers: reqHeaders, body: bodyStr);

    if (autoHandleChallenges && response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List &&
            jsonResponse.isNotEmpty &&
            jsonResponse.first is Map &&
            jsonResponse.first.containsKey('id')) {
          return await resolveChallengesAndRetry(
            jsonResponse,
            () => cookieClient.post(uri, headers: reqHeaders, body: bodyStr),
          );
        }
      } catch (_) {
        // Not a JSON array challenge, proceed normally
      }
    }

    return response;
  }

  /// Executes an HTTP DELETE request relative to [config.baseHttpUri].
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = config.baseHttpUri.resolve(endpoint);
    final reqHeaders = <String, String>{
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    return await cookieClient.delete(uri, headers: reqHeaders);
  }

  /// Closes client connections and stops timers.
  void close() {
    stopSessionTickler();
    cookieClient.close();
  }
}
