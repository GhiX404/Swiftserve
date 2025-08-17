import 'package:flutter/material.dart';
// Make sure MenuItem is accessible here

class MenuItem {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': id,
      'quantity': quantity,
      'price': price,
    };
  }
}

class CartModel extends ChangeNotifier {
  final List<MenuItem> _cartItems = [];

  List<MenuItem> get cartItems => _cartItems;

  double get totalAmount => _cartItems.fold(
    0, (total, item) => total + (item.price * item.quantity)
  );

  int get itemCount => _cartItems.fold(
    0, (total, item) => total + item.quantity
  );

  bool isInCart(int menuId) {
    return _cartItems.any((item) => item.id == menuId);
  }

  void add(MenuItem item) {
    final existingIndex = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(item);
    }
    
    notifyListeners();
  }

  void remove(MenuItem item) {
    final existingIndex = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].quantity > 1) {
        _cartItems[existingIndex].quantity--;
      } else {
        _cartItems.removeAt(existingIndex);
      }
    }
    
    notifyListeners();
  }
  
  void removeItem(MenuItem item) {
    _cartItems.removeWhere((cartItem) => cartItem.id == item.id);
    notifyListeners();
  }

  void clear() {
    _cartItems.clear();
    notifyListeners();
  }
  
  List<Map<String, dynamic>> toOrderItems() {
    return _cartItems.map((item) => item.toJson()).toList();
  }
}
