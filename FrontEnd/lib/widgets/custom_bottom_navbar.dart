import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute;
  final Color teal;

  const CustomBottomNavBar({
    Key? key,
    required this.currentRoute,
    this.teal = const Color(0xFF006D77),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {"label": "Home", "route": "/home", "icon": Icons.home},
      {"label": "Menu", "route": "/menu", "icon": Icons.restaurant_menu},
      {"label": "Cart", "route": "/cart", "icon": Icons.shopping_cart},
      {"label": "Orders", "route": "/orders", "icon": Icons.receipt_long},
      {"label": "Profile", "route": "/profile", "icon": Icons.person},
    ];

    return Container(
      color: teal,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = currentRoute == item["route"] as String;
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                Navigator.pushReplacementNamed(context, item["route"] as String);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  Icon(
                    item["icon"] as IconData,
                    color: isActive ? teal : Colors.white,
                    size: 20,
                  ),
                  if (isActive) SizedBox(width: 8),
                  if (isActive)
                    Text(
                      item["label"] as String,
                      style: TextStyle(
                        color: teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 