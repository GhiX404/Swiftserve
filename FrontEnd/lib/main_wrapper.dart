import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'main.dart';

class MainWrapper extends StatelessWidget {
  final bool isLoggedIn;
  
  const MainWrapper({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    );
  }
} 