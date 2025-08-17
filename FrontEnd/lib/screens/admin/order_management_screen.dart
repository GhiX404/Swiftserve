import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  Future<List<dynamic>>? _ordersFuture;
  Map<int, String> _menuItemNames = {};
  Map<int, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _ordersFuture ??= _fetchOrders();
    _fetchMenuItems();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _fetchMenuItems() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiService.menuUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> menuItems = json.decode(response.body);
        setState(() {
          for (var item in menuItems) {
            _menuItemNames[item['id']] = item['name'];
          }
        });
      }
    } catch (e) {
      print('Error fetching menu items: $e');
    }
  }

  Future<List<dynamic>> _fetchOrders() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(ApiService.ordersUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> orders = json.decode(response.body);
      
      // Extract user IDs to fetch user names
      final Set<int> userIds = {};
      for (var order in orders) {
        if (order['user'] is int) {
          userIds.add(order['user']);
        } else if (order['user'] is Map && order['user']['id'] != null) {
          final userId = order['user']['id'];
          final userName = order['user']['name'];
          _userNames[userId] = userName;
        }
      }
      
      // Fetch user names for IDs
      if (userIds.isNotEmpty) {
        await _fetchUserNames(userIds.toList());
      }
      
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }
  
  Future<void> _fetchUserNames(List<int> userIds) async {
    try {
      for (var userId in userIds) {
        if (_userNames.containsKey(userId)) continue;
        
        final token = await _getToken();
        final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/api/user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          setState(() {
            _userNames[userId] = userData['name'] ?? 'User $userId';
          });
        } else {
          setState(() {
            _userNames[userId] = 'User $userId';
          });
        }
      }
    } catch (e) {
      print('Error fetching user names: $e');
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  String _getUserName(dynamic user) {
    if (user is Map) {
      return user['name'] ?? 'Unknown User';
    } else if (user is int) {
      return _userNames[user] ?? 'User $user';
    }
    return 'Unknown User';
  }

  String _getMenuItemName(dynamic menuItemId) {
    if (menuItemId is int) {
      return _menuItemNames[menuItemId] ?? 'Item $menuItemId';
    }
    return 'Unknown Item';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Order Management'),
        backgroundColor: teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin-dashboard'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<dynamic>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No orders found.'));
            }

            final orders = snapshot.data!;
            
            // Sort orders by date (newest first)
            orders.sort((a, b) {
              final dateA = a['createdAt'] != null ? DateTime.parse(a['createdAt']) : DateTime(1970);
              final dateB = b['createdAt'] != null ? DateTime.parse(b['createdAt']) : DateTime(1970);
              return dateB.compareTo(dateA);
            });
            
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final userName = _getUserName(order['user']);
                
                // Parse created date
                String formattedDate = 'Unknown Date';
                if (order['createdAt'] != null) {
                  try {
                    final createdAt = DateTime.parse(order['createdAt']);
                    formattedDate = DateFormat.yMMMd().add_jm().format(createdAt);
                  } catch (e) {
                    // Use default if date parsing fails
                  }
                }

                // Filter out non-map items from orderItems
                List<dynamic> orderItems = [];
                if (order['orderItems'] != null && order['orderItems'] is List) {
                  orderItems = (order['orderItems'] as List)
                      .where((item) => item is Map)
                      .toList();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ExpansionTile(
                    title: Text('Order #${order['id'] ?? 'Unknown'} - $userName'),
                    subtitle: Text('Status: ${order['status'] ?? 'Unknown'} \nDate: $formattedDate'),
                    children: orderItems.map<Widget>((item) {
                      if (item is! Map) return SizedBox.shrink();
                      
                      final menuItemId = item['menuItem'];
                      final itemName = _getMenuItemName(menuItemId);
                      final quantity = '${item['quantity'] ?? 0}';
                      final price = '₹${item['price'] ?? 0}';
                      
                      return ListTile(
                        title: Text(itemName),
                        subtitle: Text('Quantity: $quantity'),
                        trailing: Text(price),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 