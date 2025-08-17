import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Menu Item Model ---
class MenuItem {
  final String name;
  final String price;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['itemname'],
      price: json['itemprice'],
      imageUrl: json['itemimagelink'],
    );
  }
}

// --- Sample Data (from your JSON) ---
final List<MenuItem> menuItems = [
  MenuItem(
    name: "Masala Dosa",
    price: "40",
    imageUrl: "https://example.com/images/masala_dosa.png",
  ),
  MenuItem(
    name: "Idli Sambar",
    price: "30",
    imageUrl: "https://example.com/images/idli_sambar.png",
  ),
  MenuItem(
    name: "Veg Fried Rice",
    price: "70",
    imageUrl: "https://example.com/images/veg_fried_rice.png",
  ),
  MenuItem(
    name: "Paneer Butter Masala",
    price: "120",
    imageUrl: "https://example.com/images/paneer_butter_masala.png",
  ),
  MenuItem(
    name: "Chappathi Kurma",
    price: "50",
    imageUrl: "https://example.com/images/chappathi_kurma.png",
  ),
  MenuItem(
    name: "Poha",
    price: "35",
    imageUrl: "https://example.com/images/poha.png",
  ),
  MenuItem(
    name: "Poori Bhaji",
    price: "45",
    imageUrl: "https://example.com/images/poori_bhaji.png",
  ),
  MenuItem(
    name: "Tea",
    price: "10",
    imageUrl: "https://example.com/images/tea.png",
  ),
  MenuItem(
    name: "Coffee",
    price: "15",
    imageUrl: "https://example.com/images/coffee.png",
  ),
];

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

// --- MenuPage ---
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<MenuItem> _menuItems = [];
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }
  
  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final List<dynamic> response = await _apiService.getMenuItems();
      setState(() {
        _menuItems = response.map((item) => MenuItem.fromJson(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load menu items: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: CustomBottomNavBar(
        currentRoute: '/menu',
        teal: teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  GestureDetector(
                    onTap: () {
                      // Show user profile or logout dialog
                      _showProfileOptions(context);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: teal,
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text("Menu",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: teal)),

              const SizedBox(height: 20),
              
              // Cart badge
              Consumer<CartModel>(
                builder: (context, cart, child) {
                  return cart.itemCount > 0
                    ? GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/cart'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: teal,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${cart.itemCount} items | ₹${cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
                },
              ),

              // Menu content based on loading/error state
              _isLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: teal),
                    ),
                  )
                : _error != null
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMenuItems,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teal,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _menuItems.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text('No menu items available'),
                        ),
                      )
                    : Expanded(
                        child: GridView.builder(
                          itemCount: _menuItems.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            return menuItemCard(_menuItems[index], context);
                          },
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItemCard(MenuItem item, BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white,
                  child: Icon(Icons.fastfood, color: teal, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "₹${item.price.toStringAsFixed(2)}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Consumer<CartModel>(
            builder: (context, cart, child) {
              final isInCart = cart.isInCart(item.id);
              return isInCart
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => cart.remove(item),
                          icon: const Icon(Icons.remove, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${cart.cartItems.firstWhere((cartItem) => cartItem.id == item.id).quantity}',
                            style: TextStyle(color: teal, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => cart.add(item),
                          icon: const Icon(Icons.add, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        cart.add(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: background,
                        foregroundColor: teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text("Add to Cart"),
                    );
            },
          )
        ],
      ),
    );
  }
  
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person, color: teal),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile page
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: teal),
                title: const Text('Logout'),
                onTap: () async {
                  Navigator.pop(context);
                  // Clear preferences and navigate to login
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
