import 'package:flutter/material.dart';

class MenuItem {
  final int id;
  final String name;
  final double price;
  final int stock;
  final List<String> tags;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.tags,
    this.imageUrl = '',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic tagsData) {
      if (tagsData == null) return [];
      if (tagsData is List) {
        return tagsData.map((tag) {
          if (tag is String) return tag;
          if (tag is Map && tag['name'] != null) return tag['name'].toString();
          return '';
        }).where((tag) => tag.isNotEmpty).toList();
      }
      return [];
    }

    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'].toDouble(),
      stock: json['stock'],
      tags: parseTags(json['tags']),
      // Use a placeholder image if none is provided
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150?text=${json['name']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  // Method specifically for creating order items
  Map<String, dynamic> toOrderItem(int quantity) {
    return {
      'menuItemId': id,
      'quantity': quantity,
    };
  }
} 