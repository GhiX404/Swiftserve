import 'package:flutter/material.dart';

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
