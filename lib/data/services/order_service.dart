import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/data/constants.dart';
import 'package:client/data/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    // print('Access Token: $token'); // Debug token
    if (token == null || token.isEmpty || token == 'null') {
      return null;
    }
    return token;
  }

  Future<List<Order>> fetchOrders() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    try {
      final response = await http.get(
        Uri.parse('${KConstants.baseUrl}/orders/list/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // print('API Status Code: ${response.statusCode}'); // Debug status code
      // print('API Response Body: ${response.body}'); // Debug response body

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        List<dynamic> ordersList;

        // Handle both Map and List responses
        if (jsonData is Map<String, dynamic>) {
          // Try common keys: "orders", "data", "results"
          ordersList = jsonData['orders'] ?? jsonData['data'] ?? jsonData['results'] ?? [];
          if (ordersList is! List) {
            throw Exception('Expected a list of orders, got: $ordersList');
          }
        } else if (jsonData is List<dynamic>) {
          ordersList = jsonData;
        } else {
          throw Exception('Unexpected response format: $jsonData');
        }

        return ordersList.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Fetch Orders Error: $e'); // Debug error
      rethrow; // Pass error to FutureBuilder
    }
  }
}