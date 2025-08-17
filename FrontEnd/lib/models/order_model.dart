import 'menu_item.dart';

class OrderItem {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final dynamic menuItemData; // Can be either MenuItem object or just an ID

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.menuItemData,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle case where menuItem is just an ID (int)
    if (json['menuItem'] is int) {
      final menuItemId = json['menuItem'] as int;
      return OrderItem(
        id: json['id'] ?? menuItemId,
        name: 'Item #$menuItemId', // Default name when only ID is available
        price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'].toDouble(),
        quantity: json['quantity'],
        menuItemData: menuItemId,
      );
    }
    
    // Handle case where menuItem is a Map
    if (json['menuItem'] is Map) {
      final menuItem = json['menuItem'] as Map<String, dynamic>;
      return OrderItem(
        id: json['id'] ?? menuItem['id'],
        name: menuItem['name'],
        price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'].toDouble(),
        quantity: json['quantity'],
        menuItemData: MenuItem(
          id: menuItem['id'],
          name: menuItem['name'],
          price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'].toDouble(),
          stock: menuItem['stock'] ?? 0,
          tags: _parseTagsFromJson(menuItem['tags']),
          imageUrl: menuItem['imageUrl'] ?? 'https://via.placeholder.com/150',
        ),
      );
    }
    
    // Fallback case
    return OrderItem(
      id: json['id'] ?? 0,
      name: 'Unknown Item',
      price: json['price'] is int ? (json['price'] as int).toDouble() : (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      menuItemData: 0,
    );
  }
  
  // Helper method to parse tags
  static List<String> _parseTagsFromJson(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) {
      return tags.map((tag) {
        if (tag is String) return tag;
        if (tag is Map && tag['name'] != null) return tag['name'].toString();
        return '';
      }).where((tag) => tag.isNotEmpty).toList();
    }
    return [];
  }
}

class Order {
  final int id;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;
  final String createdAt;
  final String? userId;
  final String? rfidTag;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.userId,
    this.rfidTag,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parseOrderItems(dynamic orderItems) {
      if (orderItems == null) return [];
      if (orderItems is List) {
        return orderItems
            .where((item) => item is Map) // Filter out non-Map items
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    return Order(
      id: json['id'],
      status: json['status'],
      totalAmount: json['totalAmount'] is int 
          ? (json['totalAmount'] as int).toDouble() 
          : json['totalAmount'].toDouble(),
      items: parseOrderItems(json['orderItems']),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      userId: json['userId']?.toString(),
      rfidTag: json['rfidTag'],
    );
  }
} 