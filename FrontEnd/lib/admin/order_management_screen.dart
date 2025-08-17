import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> with SingleTickerProviderStateMixin {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  List<Order> _orders = [];
  String? _error;
  
  late TabController _tabController;
  
  final List<String> _statusFilters = [
    'All',
    'CREATED',
    'PAID',
    'AWAITING_CONFIRMATION',
    'DISPATCHED',
    'COMPLETED',
    'CANCELLED',
  ];
  
  String _currentFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentFilter = _statusFilters[_tabController.index];
        });
      }
    });
    _fetchOrders();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // TODO: Backend does not have a 'getAllOrders' endpoint.
      // final orders = await _apiService.getAllOrders();
      // setState(() {
      //   _orders = orders;
      // });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (newStatus == 'DISPATCHED') {
         await _apiService.dispatchOrder(int.parse(orderId));
      } else {
        // TODO: Implement other status updates if needed.
        print('Status update for $newStatus not implemented.');
      }
      _fetchOrders();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #$orderId status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter orders based on the selected tab
    List<Order> filteredOrders = _orders;
    if (_currentFilter != 'All') {
      filteredOrders = _orders.where((order) => order.status == _currentFilter).toList();
    }
    
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: teal,
        title: const Text('Order Management', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _statusFilters.map((status) => Tab(text: _formatStatus(status))).toList(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: teal))
          : _error != null
              ? Center(
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
                        onPressed: _fetchOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No ${_currentFilter == 'All' ? '' : _currentFilter.toLowerCase()} orders found',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredOrders.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
    );
  }
  
  Widget _buildOrderCard(Order order) {
    final createdAt = DateFormat('MMM d, yyyy · h:mm a')
        .format(DateTime.parse(order.createdAt));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatStatus(order.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Created: $createdAt'),
            const SizedBox(height: 4),
            Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        children: [
          const Divider(),
          // Order items
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.quantity}x ${item.name}'),
                  Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          
          // User info if available
          if (order.userId != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('User ID: ${order.userId}'),
                ],
              ),
            ),
          
          // RFID info if available
          if (order.rfidTag != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.nfc, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('RFID: ${order.rfidTag}'),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildActionButtons(order),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  List<Widget> _buildActionButtons(Order order) {
    List<Widget> buttons = [];
    
    switch (order.status) {
      case 'CREATED':
        buttons.add(
          _actionButton(
            label: 'Mark as Paid',
            color: Colors.green,
            onPressed: () => _updateOrderStatus(order.id.toString(), 'PAID'),
          ),
        );
        buttons.add(
          _actionButton(
            label: 'Cancel',
            color: Colors.red,
            onPressed: () => _updateOrderStatus(order.id.toString(), 'CANCELLED'),
          ),
        );
        break;
        
      case 'PAID':
        buttons.add(
          _actionButton(
            label: 'Ready for Collection',
            color: Colors.purple,
            onPressed: () => _updateOrderStatus(order.id.toString(), 'AWAITING_CONFIRMATION'),
          ),
        );
        buttons.add(
          _actionButton(
            label: 'Cancel',
            color: Colors.red,
            onPressed: () => _updateOrderStatus(order.id.toString(), 'CANCELLED'),
          ),
        );
        break;
        
      case 'AWAITING_CONFIRMATION':
        buttons.add(
          _actionButton(
            label: 'Mark as Dispatched',
            color: Colors.amber,
            onPressed: () => _updateOrderStatus(order.id.toString(), 'DISPATCHED'),
          ),
        );
        break;
        
      case 'DISPATCHED':
        buttons.add(
          _actionButton(
            label: 'Mark as Completed',
            color: Colors.green,
            onPressed: () => _updateOrderStatus(order.id.toString(), 'COMPLETED'),
          ),
        );
        break;
    }
    
    return buttons;
  }
  
  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'CREATED':
        return Colors.blue;
      case 'PAID':
        return Colors.orange;
      case 'AWAITING_CONFIRMATION':
        return Colors.purple;
      case 'DISPATCHED':
        return Colors.amber;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _formatStatus(String status) {
    switch (status) {
      case 'CREATED':
        return 'Created';
      case 'PAID':
        return 'Paid';
      case 'AWAITING_CONFIRMATION':
        return 'Ready for Collection';
      case 'DISPATCHED':
        return 'Dispatched';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
} 