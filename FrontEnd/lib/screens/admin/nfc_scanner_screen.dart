import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class NfcScannerScreen extends StatefulWidget {
  const NfcScannerScreen({Key? key}) : super(key: key);

  @override
  _NfcScannerScreenState createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen> with SingleTickerProviderStateMixin {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  // Tab controller
  late TabController _tabController;
  
  // Registration tab
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  // Orders tab
  final TextEditingController _scanRfidController = TextEditingController();
  Map<String, dynamic>? _studentInfo;
  List<dynamic> _studentOrders = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int? _studentId;
  bool _otpSent = false;
  
  // NFC scanning
  bool _isNfcAvailable = false;
  bool _isScanning = false;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _rfidController.dispose();
    _otpController.dispose();
    _scanRfidController.dispose();
    _tabController.dispose();
    _stopNfcScan();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    try {
      NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
      setState(() {
        _isNfcAvailable = availability == NFCAvailability.available;
      });
      
      if (_isNfcAvailable) {
        // Start scanning when the screen loads
        _startNfcScan();
      }
    } catch (e) {
      setState(() {
        _isNfcAvailable = false;
        _errorMessage = 'Error checking NFC: ${e.toString()}';
      });
    }
  }

  Future<void> _startNfcScan() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    _scanTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      try {
        // Poll for NFC tags
        NFCTag tag = await FlutterNfcKit.poll(
          timeout: Duration(seconds: 1),
          iosMultipleTagMessage: "Multiple tags found!",
          iosAlertMessage: "Scanning for NFC tags",
        );
        
        String uid = tag.id;
        
        if (_tabController.index == 0) {
          // Registration tab
          setState(() {
            _rfidController.text = uid;
            _successMessage = 'RFID tag detected: $uid';
          });
        } else {
          // Orders tab
          setState(() {
            _scanRfidController.text = uid;
            _successMessage = 'RFID tag detected: $uid';
          });
          _fetchStudentByRfid(uid);
        }
        
        // Stop scanning after successful read
        await FlutterNfcKit.finish();
        
      } catch (e) {
        // Ignore timeouts, which are expected when no tag is present
        if (!e.toString().contains('timeout')) {
          setState(() {
            _errorMessage = 'Error scanning NFC: ${e.toString()}';
          });
        }
      }
    });
  }

  void _stopNfcScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
    setState(() {
      _isScanning = false;
    });
    FlutterNfcKit.finish();
  }

  Future<void> _restartNfcScan() async {
    _stopNfcScan();
    _startNfcScan();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _lookupStudentByEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a student email';
        _successMessage = null;
        _studentId = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiService.userLookupUrl(_emailController.text)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _studentId = data['id'];
          _successMessage = 'Student found: ${data['name']}';
        });
      } else {
        setState(() {
          _errorMessage = 'Student not found';
          _studentId = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _studentId = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestOtp() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a student email';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final apiService = ApiService();
      await apiService.requestRfidOtpForUser(_emailController.text);
      
      setState(() {
        _otpSent = true;
        _successMessage = 'OTP sent to ${_emailController.text}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending OTP: ${e.toString()}';
        _otpSent = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerRfid() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a student email';
        _successMessage = null;
      });
      return;
    }

    if (_rfidController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an RFID UID';
        _successMessage = null;
      });
      return;
    }

    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP sent to the student';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final apiService = ApiService();
      await apiService.adminRegisterRfidWithOtp(
        _rfidController.text.trim(),
        _emailController.text.trim(),
        _otpController.text.trim()
      );

      setState(() {
        _successMessage = 'RFID registered successfully';
        _rfidController.clear();
        _otpController.clear();
        _otpSent = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStudentByRfid(String rfidUid) async {
    if (rfidUid.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter or scan an RFID UID';
        _successMessage = null;
        _studentInfo = null;
        _studentOrders = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await _getToken();
      
      // First, get student info by RFID
      final userResponse = await http.get(
        Uri.parse(ApiService.rfidUserUrl(rfidUid)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        setState(() {
          _studentInfo = userData;
          _successMessage = 'Student found: ${userData['name']}';
        });
        
        // Then, get student orders
        final ordersResponse = await http.get(
          Uri.parse(ApiService.ordersByUserUrl(userData['id'])),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (ordersResponse.statusCode == 200) {
          final ordersData = json.decode(ordersResponse.body);
          setState(() {
            _studentOrders = ordersData;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to fetch orders';
            _studentOrders = [];
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Student not found with this RFID';
          _studentInfo = null;
          _studentOrders = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _studentInfo = null;
        _studentOrders = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('NFC Scanner'),
        backgroundColor: teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin-dashboard'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.app_registration), text: 'Register RFID'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Student Orders'),
          ],
          onTap: (index) {
            // Clear previous messages when switching tabs
            setState(() {
              _errorMessage = null;
              _successMessage = null;
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Register RFID Tab
          _buildRegisterRfidTab(),
          
          // Student Orders Tab
          _buildStudentOrdersTab(),
        ],
      ),
      floatingActionButton: _isNfcAvailable ? FloatingActionButton(
        onPressed: _restartNfcScan,
        backgroundColor: teal,
        child: Icon(_isScanning ? Icons.nfc : Icons.play_arrow),
        tooltip: _isScanning ? 'NFC Scanning Active' : 'Start NFC Scanning',
      ) : null,
    );
  }

  Widget _buildRegisterRfidTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register RFID Tag',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // NFC Status
                  _buildNfcStatusBanner(),
                  SizedBox(height: 16),
                  
                  // Step 1: Enter student email
                  Text('Step 1: Enter Student Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Student Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _requestOtp,
                        child: Text('Send OTP'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Step 2: Enter OTP
                  Text('Step 2: Enter OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'OTP Code',
                      border: OutlineInputBorder(),
                      hintText: 'Enter the OTP sent to the student',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  
                  // Step 3: Scan RFID
                  Text('Step 3: Enter RFID UID', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _rfidController,
                    decoration: InputDecoration(
                      labelText: 'RFID UID',
                      border: OutlineInputBorder(),
                      hintText: _isNfcAvailable ? 'Scan or enter RFID UID' : 'Enter RFID UID manually',
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerRfid,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: teal,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Register RFID'),
                  ),
                  
                  // Error/Success messages
                  _buildMessageBanners(),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Enter the student\'s email address and click "Send OTP"'),
                  Text('2. Ask the student to check their email for the OTP and enter it'),
                  Text('3. Hold an RFID tag near your device to scan it automatically'),
                  Text('4. Click "Register RFID" to link the RFID tag to the student'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentOrdersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Student RFID',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // NFC Status
                  _buildNfcStatusBanner(),
                  SizedBox(height: 16),
                  
                  // RFID Input
                  TextField(
                    controller: _scanRfidController,
                    decoration: InputDecoration(
                      labelText: 'RFID UID',
                      border: OutlineInputBorder(),
                      hintText: _isNfcAvailable ? 'Scan or enter RFID UID' : 'Enter RFID UID manually',
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Lookup button
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _fetchStudentByRfid(_scanRfidController.text),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: teal,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Lookup Student'),
                  ),
                  
                  // Error/Success messages
                  _buildMessageBanners(),
                ],
              ),
            ),
          ),
          
          // Student Info
          if (_studentInfo != null) ...[
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ListTile(
                      title: Text(_studentInfo!['name'] ?? 'Unknown Name'),
                      subtitle: Text(_studentInfo!['email'] ?? 'Unknown Email'),
                      leading: CircleAvatar(
                        child: Text((_studentInfo!['name'] as String).isNotEmpty 
                            ? (_studentInfo!['name'] as String)[0].toUpperCase() 
                            : '?'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Student Orders
          if (_studentOrders.isNotEmpty) ...[
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _studentOrders.length,
                      itemBuilder: (context, index) {
                        final order = _studentOrders[index];
                        final createdAt = DateTime.parse(order['createdAt']);
                        final formattedDate = DateFormat.yMMMd().add_jm().format(createdAt);
                        
                        return ExpansionTile(
                          title: Text('Order #${order['id']} - ${order['status']}'),
                          subtitle: Text('Date: $formattedDate\nTotal: ₹${order['totalAmount']}'),
                          children: _buildOrderItems(order),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (_studentInfo != null && _studentOrders.isEmpty) ...[
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No orders found for this student.'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildOrderItems(Map<String, dynamic> order) {
    List<Widget> widgets = [];
    
    if (order['orderItems'] != null && order['orderItems'] is List) {
      final orderItems = (order['orderItems'] as List)
          .where((item) => item is Map)
          .toList();
      
      for (var item in orderItems) {
        if (item is Map) {
          final menuItemId = item['menuItem'];
          final quantity = item['quantity'] ?? 0;
          final price = item['price'] ?? 0;
          
          widgets.add(
            FutureBuilder<String>(
              future: _fetchMenuItemName(menuItemId),
              builder: (context, snapshot) {
                final itemName = snapshot.data ?? 'Item $menuItemId';
                
                return ListTile(
                  title: Text(itemName),
                  subtitle: Text('Quantity: $quantity'),
                  trailing: Text('₹$price'),
                );
              },
            ),
          );
        }
      }
    }
    
    return widgets;
  }
  
  // Cache for menu item names
  final Map<int, String> _menuItemNames = {};
  
  Future<String> _fetchMenuItemName(int menuItemId) async {
    // Return from cache if available
    if (_menuItemNames.containsKey(menuItemId)) {
      return _menuItemNames[menuItemId]!;
    }
    
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/menu/$menuItemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final menuData = json.decode(response.body);
        final name = menuData['name'] ?? 'Item $menuItemId';
        _menuItemNames[menuItemId] = name;
        return name;
      }
    } catch (e) {
      print('Error fetching menu item name: $e');
    }
    
    return 'Item $menuItemId';
  }

  Widget _buildNfcStatusBanner() {
    return Container(
      padding: EdgeInsets.all(8),
      color: _isNfcAvailable ? Colors.green.shade100 : Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            _isNfcAvailable ? Icons.nfc : Icons.nfc_outlined,
            color: _isNfcAvailable ? Colors.green.shade900 : Colors.orange.shade900,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _isNfcAvailable 
                  ? _isScanning 
                      ? 'NFC scanning active. Hold an RFID tag near your device.'
                      : 'NFC available. Tap the floating button to start scanning.'
                  : 'NFC not available. Please enter RFID UID manually.',
              style: TextStyle(
                color: _isNfcAvailable ? Colors.green.shade900 : Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBanners() {
    return Column(
      children: [
        if (_errorMessage != null) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.red.shade100,
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        ],
        
        if (_successMessage != null) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.green.shade100,
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade900),
            ),
          ),
        ],
      ],
    );
  }
} 