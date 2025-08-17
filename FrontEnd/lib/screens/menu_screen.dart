import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../providers/cart_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  late Future<List<MenuItem>> _menuItemsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _apiService.getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: CustomBottomNavBar(
        currentRoute: '/menu',
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Snuggy", style: TextStyle(color: Colors.white)),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text(
                "Menu",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: teal,
                ),
              ),

              SizedBox(height: 20),

              // Menu Grid with FutureBuilder
              Expanded(
                child: FutureBuilder<List<MenuItem>>(
                  future: _menuItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: teal),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading menu: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No menu items available',
                          style: TextStyle(color: teal),
                        ),
                      );
                    } else {
                      return GridView.builder(
                        itemCount: snapshot.data!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          return menuItemCard(snapshot.data![index], context);
                        },
                      );
                    }
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
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
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
          SizedBox(height: 8),
          Text(
            "${item.name}\n₹${item.price.toStringAsFixed(2)}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              cart.addToCart(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} added to cart!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Add to Cart"),
          )
        ],
      ),
    );
  }
}