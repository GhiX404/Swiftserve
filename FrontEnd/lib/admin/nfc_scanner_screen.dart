import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/nfc_service.dart';
import '../models/order_model.dart';

class NfcScannerScreen extends StatefulWidget {
  const NfcScannerScreen({super.key});

  @override
  _NfcScannerScreenState createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen> with SingleTickerProviderStateMixin {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final ApiService _apiService = ApiService();
  final NfcService _nfcService = NfcService();
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  List<Order> _userOrders = [];
  bool _isLoading = false;
  String? _error;
  String? _scanStatus;
  String? _scannedUuid;
  bool _isNfcSupported = true;
  Order? _scannedOrder;
  
  StreamSubscription? _statusSubscription;
  StreamSubscription? _valueSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation for scanner effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    
    // Initialize NFC hardware
    _initializeNfc();
    
    // Listen to NFC scan status changes
    _statusSubscription = _nfcService.scanStatusStream.listen((status) {
      setState(() {
        switch (status) {
          case NfcScanStatus.idle:
            _scanStatus = 'Ready to scan';
            _animationController.stop();
            break;
          case NfcScanStatus.scanning:
            _scanStatus = 'Scanning for NFC card...';
            if (!_animationController.isAnimating) {
              _animationController.repeat(reverse: true);
            }
            break;
          case NfcScanStatus.success:
            _scanStatus = 'NFC tag scanned successfully';
            _animationController.stop();
            _animationController.value = 0;
            break;
          case NfcScanStatus.error:
            _scanStatus = 'Error scanning NFC tag';
            _animationController.stop();
            break;
          case NfcScanStatus.notSupported:
            _scanStatus = 'NFC not supported on this device';
            _isNfcSupported = false;
            _animationController.stop();
            break;
        }
      });
    });
    
    // Listen to NFC tag UUID values
    _valueSubscription = _nfcService.tagUuidStream.listen((uuid) {
      setState(() {
        _scannedUuid = uuid;
      });
      _fetchOrderByUuid(uuid);
    });
  }
  
  Future<void> _initializeNfc() async {
    try {
      bool isSupported = await _nfcService.initializeHardware();
      setState(() {
        _isNfcSupported = isSupported;
        if (!isSupported) {
          _error = 'NFC is not supported on this device';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize NFC scanner: $e';
        _isNfcSupported = false;
      });
    }
  }
  
  void _startScanning() {
    if (!_isNfcSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC is not supported on this device'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _userOrders = [];
      _scannedUuid = null;
      _error = null;
    });
    
    _nfcService.startScan();
  }
  
  void _stopScanning() {
    _nfcService.stopScan();
  }
  
  Future<void> _fetchOrderByUuid(String uuid) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _scannedOrder = null;
    });
    
    try {
      final order = await _apiService.getOrderByRfid(uuid);
      setState(() {
        _scannedOrder = order;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch order: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _dispatchOrder(String orderId) async {
    try {
      await _apiService.dispatchOrder(int.parse(orderId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order dispatched successfully')),
      );
      // Reset the screen
      setState(() {
        _userOrders = [];
        _scannedUuid = null;
        _error = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to dispatch order: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _statusSubscription?.cancel();
    _valueSubscription?.cancel();
    _nfcService.stopScan();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: teal,
        title: const Text('NFC Scanner', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _startScanning,
          ),
        ],
      ),
      body: Column(
        children: [
          // NFC Scanner Section
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                // Scanner animation
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // NFC card icon
                      Icon(
                        Icons.nfc,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      
                      // Scanning line animation
                      if (_nfcService.currentStatus == NfcScanStatus.scanning)
                        Positioned(
                          top: _animation.value * 180,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: teal,
                          ),
                        ),
                      
                      // Success indicator
                      if (_nfcService.currentStatus == NfcScanStatus.success)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      
                      // Error indicator
                      if (_nfcService.currentStatus == NfcScanStatus.error || 
                          _nfcService.currentStatus == NfcScanStatus.notSupported)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Status text
                Text(
                  _scanStatus ?? 'Ready to scan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _nfcService.currentStatus == NfcScanStatus.notSupported ? 
                      Colors.red : teal,
                  ),
                ),
                
                // UUID value
                if (_scannedUuid != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'UUID: $_scannedUuid',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Scan button
                ElevatedButton.icon(
                  onPressed: _isNfcSupported ? 
                    (_nfcService.currentStatus == NfcScanStatus.scanning
                      ? _stopScanning
                      : _startScanning) : null,
                  icon: Icon(
                    _nfcService.currentStatus == NfcScanStatus.scanning
                        ? Icons.stop
                        : Icons.nfc,
                  ),
                  label: Text(
                    _nfcService.currentStatus == NfcScanStatus.scanning
                        ? 'Stop Scanning'
                        : 'Start Scanning',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _nfcService.currentStatus == NfcScanStatus.scanning
                        ? Colors.red
                        : teal,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
                
                if (!_isNfcSupported) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'NFC is not supported on this device',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Orders section
          Expanded(
            child: _isLoading
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
                              onPressed: _scannedUuid != null && _isNfcSupported
                                  ? () => _fetchOrderByUuid(_scannedUuid!)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teal,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _scannedOrder == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _scannedUuid == null
                                      ? 'Scan an NFC card to view orders'
                                      : 'No orders found for this NFC tag',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: 1, // Only one order is scanned at a time
                            itemBuilder: (context, index) {
                              final order = _scannedOrder!;
                              final bool isPaid = order.status == 'PAID';
                              final bool isDispatched = order.status == 'DISPATCHED';
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Order header
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order #${order.id.toString().substring(0, 8)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDispatched
                                                  ? Colors.green.withOpacity(0.1)
                                                  : isPaid
                                                      ? Colors.blue.withOpacity(0.1)
                                                      : Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              order.status,
                                              style: TextStyle(
                                                color: isDispatched
                                                    ? Colors.green
                                                    : isPaid
                                                        ? Colors.blue
                                                        : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const Divider(height: 24),
                                      
                                      // Order items
                                      ...order.items.map((item) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${item.quantity}x ${item.name}',
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                            Text(
                                              '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                      
                                      const Divider(height: 24),
                                      
                                      // Total
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '₹${order.totalAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: teal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Action button
                                      if (isPaid && !isDispatched)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => _dispatchOrder(order.id.toString()),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: teal,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('Mark as Dispatched'),
                                          ),
                                        ),
                                      
                                      if (isDispatched)
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: null,
                                            icon: const Icon(Icons.check_circle),
                                            label: const Text('Order Dispatched'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.green,
                                              side: const BorderSide(color: Colors.green),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
} 