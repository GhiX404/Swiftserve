import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final ApiService _apiService = ApiService();
  late Future<double> _earningsFuture;
  
  @override
  void initState() {
    super.initState();
    _earningsFuture = _apiService.getDailyEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Earnings'),
      ),
      body: FutureBuilder<double>(
        future: _earningsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No earnings data available.'));
          }
          final earnings = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Earnings for Today:', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text('\$${earnings.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
          );
        },
      ),
    );
  }
} 