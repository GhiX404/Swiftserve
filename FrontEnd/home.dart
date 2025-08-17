import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';

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

// --- HomePage ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<MenuItem> _featuredItems = [];
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
        _featuredItems = response.map((item) => MenuItem.fromJson(item)).toList();
        // Just display max 6 featured items
        if (_featuredItems.length > 6) {
          _featuredItems = _featuredItems.sublist(0, 6);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load menu items: $e';
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: CustomBottomNavBar(
        currentRoute: '/home',
        teal: teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    child: const Text(
                      "Snuggy",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showProfileOptions(context),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: teal,
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Welcome message
              Text(
                "Welcome to Snuggy",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Order delicious food from our canteen",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Banner
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: teal,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: const NetworkImage("https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?ixlib=rb-4.0.3&auto=format&fit=crop&w=1080&q=80"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      teal.withOpacity(0.7),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Special Offers",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Get 10% off on your first order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: Icons.restaurant_menu,
                    label: "Menu",
                    onTap: () => Navigator.pushNamed(context, '/menu'),
                  ),
                  _actionButton(
                    icon: Icons.shopping_cart,
                    label: "Cart",
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  _actionButton(
                    icon: Icons.receipt_long,
                    label: "Orders",
                    onTap: () => Navigator.pushNamed(context, '/orders'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Featured items section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Featured Items",
                    style: TextStyle(
                      color: teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/menu'),
                    child: Text(
                      "See All",
                      style: TextStyle(color: teal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Featured menu items grid
              _isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(color: teal),
                    ),
                  )
                : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
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
                              ),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _featuredItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/menu'),
                          child: menuItemCard(_featuredItems[index]),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItemCard(MenuItem item) {
    return Container(
      decoration: BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "₹${item.price.toStringAsFixed(2)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, size: 30, color: teal),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
