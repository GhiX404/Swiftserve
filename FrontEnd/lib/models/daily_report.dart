class DailyReport {
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int totalItemsSold;
  final List<TopSellingItem> topSellingItems;
  final Map<String, int> hourlyDistribution;
  final List<InventoryUsageItem> inventoryUsage;
  final String date;

  DailyReport({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.totalItemsSold,
    required this.topSellingItems,
    required this.hourlyDistribution,
    required this.inventoryUsage,
    required this.date,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      totalItemsSold: json['totalItemsSold'] ?? 0,
      topSellingItems: (json['topSellingItems'] as List<dynamic>?)
              ?.map((item) => TopSellingItem.fromJson(item))
              .toList() ??
          [],
      hourlyDistribution: (json['hourlyDistribution'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      inventoryUsage: (json['inventoryUsage'] as List<dynamic>?)
              ?.map((item) => InventoryUsageItem.fromJson(item))
              .toList() ??
          [],
      date: json['date'] ?? '',
    );
  }
}

class TopSellingItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  TopSellingItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class InventoryUsageItem {
  final String id;
  final String name;
  final String category;
  final int usedQuantity;
  final int remainingQuantity;
  final int alertThreshold;

  InventoryUsageItem({
    required this.id,
    required this.name,
    required this.category,
    required this.usedQuantity,
    required this.remainingQuantity,
    required this.alertThreshold,
  });

  factory InventoryUsageItem.fromJson(Map<String, dynamic> json) {
    return InventoryUsageItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      usedQuantity: json['usedQuantity'] ?? 0,
      remainingQuantity: json['remainingQuantity'] ?? 0,
      alertThreshold: json['alertThreshold'] ?? 0,
    );
  }
} 