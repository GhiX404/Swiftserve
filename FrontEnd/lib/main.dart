import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rfid_registration_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/inventory_screen.dart';
import 'screens/admin/order_management_screen.dart';
import 'screens/admin/nfc_scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Snuggy Canteen',
        theme: ThemeData(
          primaryColor: const Color(0xFF006D77),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF006D77),
            primary: const Color(0xFF006D77),
            secondary: const Color(0xFFE29578),
          ),
          scaffoldBackgroundColor: const Color(0xFFEFF6F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF006D77),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D77),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomePage(),
          '/menu': (context) => const MenuPage(),
          '/cart': (context) => const CartPage(),
          '/orders': (context) => const OrdersPage(),
          '/payment': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PaymentScreen(
              orderId: args['orderId'],
              amount: args['totalAmount'],
            );
          },
          '/profile': (context) => const ProfilePage(),
          '/rfid-registration': (context) => const RfidRegistrationScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/admin-inventory': (context) => const InventoryScreen(),
          '/admin-orders': (context) => const OrderManagementScreen(),
          '/admin-nfc': (context) => const NfcScannerScreen(),
        },
      ),
    );
  }
} 