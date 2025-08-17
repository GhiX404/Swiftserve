import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_model.dart';
import 'home.dart';
import 'menu.dart';
import 'cart.dart';
import 'orders.dart';
import 'payment.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('accessToken');
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snuggy',
      theme: ThemeData(
        primaryColor: const Color(0xFF006D77),
        scaffoldBackgroundColor: const Color(0xFFEFF6F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006D77),
          primary: const Color(0xFF006D77),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/cart': (context) => const CartPage(),
        '/orders': (context) => const OrdersPage(),
        '/payment': (context) => const PaymentPage(),
      },
    );
  }
}
