import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'services/api_service.dart';

// --- Reusable Custom Bottom Navigation Bar ---
class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute;
  final Color teal;

  const CustomBottomNavBar({
    Key? key,
    required this.currentRoute,
    required this.teal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {"label": "Home", "route": "/home"},
      {"label": "Menu", "route": "/menu"},
      {"label": "Cart", "route": "/cart"},
      {"label": "Orders", "route": "/orders"},
    ];

    return Container(
      color: teal,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = currentRoute == item["route"];
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                Navigator.pushReplacementNamed(context, item["route"]!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                item["label"]!,
                style: TextStyle(
                  color: isActive ? teal : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --- CartPage ---
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  final ApiService _apiService = ApiService();
  
  bool _isPlacingOrder = false;
  String? _orderError;

  Future<void> _placeOrder(CartModel cart) async {
    if (cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }
    
    setState(() {
      _isPlacingOrder = true;
      _orderError = null;
    });
    
    try {
      final orderItems = cart.toOrderItems();
      final response = await _apiService.createOrder(orderItems);
      
      // Clear the cart after successful order
      cart.clear();
      
      // Navigate to payment page with the order ID
      Navigator.pushReplacementNamed(
        context, 
        '/payment',
        arguments: {'orderId': response['id']},
      );
    } catch (e) {
      setState(() {
        _orderError = 'Failed to place order: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_orderError!)),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // Interactive Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentRoute: '/cart',
        teal: teal,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("Snuggy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: teal,
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Page title
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Cart",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: teal)),
              ),
              const SizedBox(height: 20),

              // Cart Items List
              Consumer<CartModel>(
                builder: (context, cart, child) {
                  if (cart.cartItems.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: teal.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: teal,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/menu');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teal,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Browse Menu',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Expanded(
                    child: ListView.builder(
                      itemCount: cart.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cart.cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Item image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item.imageUrl),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) =>
                                        const AssetImage('assets/placeholder.png'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: teal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${item.price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: teal),
                                    onPressed: () {
                                      cart.remove(item);
                                    },
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: teal),
                                    ),
                                    child: Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: teal),
                                    onPressed: () {
                                      cart.add(item);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red[300]),
                                    onPressed: () {
                                      cart.removeItem(item);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // Order summary
              Consumer<CartModel>(
                builder: (context, cart, child) {
                  if (cart.cartItems.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(fontSize: 16)),
                            Text('₹${cart.totalAmount.toStringAsFixed(2)}', 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('₹${cart.totalAmount.toStringAsFixed(2)}', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: teal)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Place Order Button
              Consumer<CartModel>(
                builder: (context, cart, child) {
                  if (cart.cartItems.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return GestureDetector(
                    onTap: _isPlacingOrder ? null : () => _placeOrder(cart),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: teal,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: _isPlacingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Place Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
