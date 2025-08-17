import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/rfid_mapping_model.dart';

class ApiService {
  static String get baseUrl {
    // Use 10.0.2.2 for Android emulator to connect to host machine's 127.0.0.1
    // Use 127.0.0.1 for web
    // For physical devices, you would use your actual machine's IP address
    if (kIsWeb) {
      return 'http://127.0.0.1:9090';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:9090';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:9090'; // iOS simulator uses 127.0.0.1
    } else {
      return 'http://127.0.0.1:9090'; // Default fallback
    }
  }

  // Auth endpoints
  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/signup';
  static String get currentUserUrl => '$baseUrl/api/user/me';

  // Menu endpoints
  static String get menuUrl => '$baseUrl/api/menu';
  static String menuItemStockUrl(int id) => '$baseUrl/api/menu/$id/stock';

  // Order endpoints
  static String get ordersUrl => '$baseUrl/api/orders';
  static String get myOrdersUrl => '$baseUrl/api/orders/my-orders';
  static String orderByIdUrl(int id) => '$baseUrl/api/orders/$id';
  static String orderDispatchUrl(int id) => '$baseUrl/api/orders/$id/dispatch';
  static String orderConfirmCollectionUrl(int id) => '$baseUrl/api/orders/$id/confirm-collection';
  static String orderPayUrl(int id) => '$baseUrl/api/orders/$id/pay/upi';
  static String ordersByUserUrl(int userId) => '$baseUrl/api/orders/user/$userId';

  // RFID endpoints
  static String get rfidAdminRegisterUrl => '$baseUrl/api/rfid/admin/register';
  static String get rfidAdminRegisterWithOtpUrl => '$baseUrl/api/rfid/admin/register-with-otp';
  static String rfidUserUrl(String rfidUid) => '$baseUrl/api/rfid/user/$rfidUid';
  static String get rfidRequestOtpUrl => '$baseUrl/api/rfid/request-otp';
  static String rfidRequestOtpForUserUrl(String email) => '$baseUrl/api/rfid/request-otp/$email';

  // User endpoints
  static String userByIdUrl(int userId) => '$baseUrl/api/user/$userId';
  static String userLookupUrl(String email) => '$baseUrl/api/user/lookup?email=$email';

  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  String? _accessToken;

  // Private constructor
  ApiService._internal();

  // Factory constructor to return the singleton instance
  factory ApiService() {
    return _instance;
  }

  Future<void> _loadToken() async {
    if (_accessToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('accessToken');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    await _loadToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Helper to handle response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed API Call: ${response.statusCode} ${response.body}');
    }
  }

  // 1. AUTH
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handleResponse(response) as Map<String, dynamic>;
    
    // Set the token on the instance and save to storage
    _accessToken = data['accessToken'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', _accessToken!);
    await prefs.setString('refreshToken', data['refreshToken']);
    return data;
  }

  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userId');
    await prefs.remove('isAdmin');
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    final data = _handleResponse(response) as Map<String, dynamic>;
    final newAccessToken = data['accessToken'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', newAccessToken);
    return newAccessToken;
  }

  // 2. MENU
  Future<List<MenuItem>> getMenu({Set<String>? tags}) async {
    var uri = Uri.parse(menuUrl);
    if (tags != null && tags.isNotEmpty) {
      uri = uri.replace(queryParameters: {'tags': tags.join(',')});
    }
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    final data = _handleResponse(response) as List<dynamic>;
    return data.map((item) => MenuItem.fromJson(item)).toList();
  }

  Future<MenuItem> addMenuItem(String name, double price, int stock, List<String> tags) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(menuUrl),
      headers: headers,
      body: jsonEncode({'name': name, 'price': price, 'stock': stock, 'tags': tags}),
    );
    final data = _handleResponse(response);
    return MenuItem.fromJson(data);
  }

  Future<MenuItem> updateStock(int menuItemId, int quantityChange) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(menuItemStockUrl(menuItemId)),
      headers: headers,
      body: jsonEncode({'quantityChange': quantityChange}),
    );
    final data = _handleResponse(response);
    return MenuItem.fromJson(data);
  }

  // 3. ORDERS
  Future<Order> createOrder(List<Map<String, dynamic>> items) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(ordersUrl),
      headers: headers,
      body: jsonEncode({'items': items}),
    );
    final data = _handleResponse(response);
    return Order.fromJson(data);
  }

  Future<Map<String, dynamic>> initiateUpiPayment(int orderId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(orderPayUrl(orderId)),
      headers: headers,
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<void> dispatchOrder(int orderId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(orderDispatchUrl(orderId)),
      headers: headers,
    );
    _handleResponse(response);
  }

  Future<void> confirmOrderCollection(int orderId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(orderConfirmCollectionUrl(orderId)),
      headers: headers,
    );
    _handleResponse(response);
  }

  Future<List<Order>> getMyOrders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(myOrdersUrl),
      headers: headers,
    );
    final data = _handleResponse(response) as List<dynamic>;
    return data.map((order) => Order.fromJson(order)).toList();
  }

  Future<Order> getOrderByRfid(String rfidUid) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/rfid/$rfidUid'),
      headers: headers,
    );
    final data = _handleResponse(response);
    return Order.fromJson(data);
  }
  
  // 4. USER & RFID
  Future<User> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(currentUserUrl),
      headers: headers,
    );
    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  Future<void> registerFcmToken(String fcmToken) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/user/fcm-token'),
      headers: headers,
      body: jsonEncode({'token': fcmToken}),
    );
    _handleResponse(response);
  }

  Future<String> generateRfidOtp() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/rfid/generate-otp'),
      headers: headers,
    );
    final data = _handleResponse(response) as Map<String, dynamic>;
    return data['otp'] as String;
  }

  Future<void> registerRfid(String rfidUid, String otp) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/rfid/register'),
      headers: headers,
      body: jsonEncode({'rfidUid': rfidUid, 'otp': otp}),
    );
    _handleResponse(response);
  }

  Future<void> adminRegisterRfid(String rfidUid, int studentId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/rfid/admin/register'),
      headers: headers,
      body: jsonEncode({'rfidUid': rfidUid, 'studentId': studentId}),
    );
    _handleResponse(response);
  }

  Future<RfidMapping> getRfidMapping(String rfidUid) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rfid/$rfidUid'),
      headers: headers,
    );
    final data = _handleResponse(response);
    return RfidMapping.fromJson(data);
  }
  
  // 5. TRANSACTIONS & EARNINGS
  Future<List<Transaction>> getAllTransactions() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: headers,
    );
    final data = _handleResponse(response) as List<dynamic>;
    return data.map((t) => Transaction.fromJson(t)).toList();
  }

  Future<List<Transaction>> getMyTransactions() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/my-transactions'),
      headers: headers,
    );
    final data = _handleResponse(response) as List<dynamic>;
    return data.map((t) => Transaction.fromJson(t)).toList();
  }

  Future<double> getDailyEarnings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/earnings/daily'),
      headers: headers,
    );
    final data = _handleResponse(response) as Map<String, dynamic>;
    // The backend returns a number, which might be int or double.
    return (data['dailyEarnings'] as num).toDouble();
  }

  Future<void> requestRfidOtp() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(rfidRequestOtpUrl),
      headers: headers,
    );
    _handleResponse(response);
  }

  Future<void> requestRfidOtpForUser(String email) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(rfidRequestOtpForUserUrl(email)),
      headers: headers,
    );
    _handleResponse(response);
  }

  Future<void> adminRegisterRfidWithOtp(String rfidUid, String email, String otp) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(rfidAdminRegisterWithOtpUrl),
      headers: headers,
      body: jsonEncode({
        'rfidUid': rfidUid,
        'email': email,
        'otp': otp
      }),
    );
    _handleResponse(response);
  }
} 