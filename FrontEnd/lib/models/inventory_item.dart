class InventoryItem {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final int alertThreshold;
  final String? lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.alertThreshold,
    this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      alertThreshold: json['alertThreshold'],
      lastUpdated: json['lastUpdated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'alertThreshold': alertThreshold,
      'lastUpdated': lastUpdated,
    };
  }
} 