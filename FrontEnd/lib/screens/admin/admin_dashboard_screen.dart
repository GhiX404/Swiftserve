import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: teal,
                ),
              ),
              SizedBox(height: 24),
              
              // Admin menu options
              _buildAdminOption(
                icon: Icons.inventory_2,
                title: 'Inventory Management',
                onTap: () => Navigator.pushNamed(context, '/admin-inventory'),
              ),
              
              _buildAdminOption(
                icon: Icons.receipt_long,
                title: 'Order Management',
                onTap: () => Navigator.pushNamed(context, '/admin-orders'),
              ),
              
              _buildAdminOption(
                icon: Icons.nfc,
                title: 'NFC Scanner',
                onTap: () => Navigator.pushNamed(context, '/admin-nfc'),
              ),
              
              SizedBox(height: 24),
              
              // Back to user mode
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Back to User Mode'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAdminOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: teal, size: 32),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
} 