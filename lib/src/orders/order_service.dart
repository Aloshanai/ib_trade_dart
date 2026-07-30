import 'dart:convert';
import '../client/ib_trade_client.dart';
import '../models/order.dart';
import '../models/position.dart';

/// Service handling order placement, modification, cancellation, positions, and account summary.
class OrderService {
  final IbTradeClient _client;

  /// Creates an [OrderService] with the given [_client].
  OrderService(this._client);

  /// Submits an order for execution on account [acctId].
  ///
  /// Endpoint: `POST /iserver/account/{acctId}/orders`
  ///
  /// Handles IBKR safety/compliance challenges automatically.
  Future<List<OrderStatus>> placeOrder(
      String acctId, OrderRequest request) async {
    final response = await _client.post(
      'iserver/account/$acctId/orders',
      body: {
        'orders': [request.toJson()],
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderStatus.fromJson(e))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        return [OrderStatus.fromJson(jsonResponse)];
      }
      return [];
    } else {
      throw Exception('Failed to place order: HTTP ${response.statusCode}');
    }
  }

  /// Modifies an existing open order [orderId] on account [acctId].
  ///
  /// Endpoint: `POST /iserver/account/{acctId}/order/{orderId}`
  Future<List<OrderStatus>> modifyOrder(
    String acctId,
    String orderId,
    OrderRequest request,
  ) async {
    final response = await _client.post(
      'iserver/account/$acctId/order/$orderId',
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderStatus.fromJson(e))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        return [OrderStatus.fromJson(jsonResponse)];
      }
      return [];
    } else {
      throw Exception('Failed to modify order: HTTP ${response.statusCode}');
    }
  }

  /// Cancels an open order [orderId] on account [acctId].
  ///
  /// Endpoint: `DELETE /iserver/account/{acctId}/order/{orderId}`
  Future<bool> cancelOrder(String acctId, String orderId) async {
    final response =
        await _client.delete('iserver/account/$acctId/order/$orderId');
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to cancel order: HTTP ${response.statusCode}');
    }
  }

  /// Fetches all open live orders across accounts.
  ///
  /// Endpoint: `GET /iserver/account/orders`
  Future<List<OrderStatus>> getOpenOrders() async {
    final response = await _client.get('iserver/account/orders');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<dynamic> ordersList = [];
      if (jsonResponse is List) {
        ordersList = jsonResponse;
      } else if (jsonResponse is Map && jsonResponse.containsKey('orders')) {
        ordersList = jsonResponse['orders'] as List;
      }

      return ordersList
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderStatus.fromJson(e))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch open orders: HTTP ${response.statusCode}');
    }
  }

  /// Fetches open positions for account [acctId].
  ///
  /// Endpoint: `GET /portfolio/{acctId}/positions/{page}`
  Future<List<Position>> getPositions(String acctId, {int page = 0}) async {
    final response = await _client.get('portfolio/$acctId/positions/$page');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .whereType<Map<String, dynamic>>()
            .map((e) => Position.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to fetch positions: HTTP ${response.statusCode}');
    }
  }

  /// Fetches summary balances and metrics for account [acctId].
  ///
  /// Endpoint: `GET /portfolio/{acctId}/summary`
  Future<AccountSummary> getAccountSummary(String acctId) async {
    final response = await _client.get('portfolio/$acctId/summary');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map<String, dynamic>) {
        return AccountSummary.fromJson(jsonResponse);
      }
      throw Exception('Invalid account summary payload structure.');
    } else {
      throw Exception(
          'Failed to fetch account summary: HTTP ${response.statusCode}');
    }
  }
}
