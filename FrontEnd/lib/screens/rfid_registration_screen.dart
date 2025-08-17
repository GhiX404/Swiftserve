import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../services/api_service.dart';

class RfidRegistrationScreen extends StatefulWidget {
  const RfidRegistrationScreen({Key? key}) : super(key: key);

  @override
  _RfidRegistrationScreenState createState() => _RfidRegistrationScreenState();
}

class _RfidRegistrationScreenState extends State<RfidRegistrationScreen> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _otpSent = false;
  
  // NFC scanning
  bool _isNfcAvailable = false;
  bool _isScanning = false;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _rfidController.dispose();
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
        setState(() {
          _rfidController.text = uid;
          _successMessage = 'RFID tag detected: $uid';
        });
        
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

  Future<void> _requestOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final apiService = ApiService();
      await apiService.requestRfidOtp();
      
      setState(() {
        _otpSent = true;
        _successMessage = 'OTP sent to your email';
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
    if (_rfidController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please scan an RFID tag';
        _successMessage = null;
      });
      return;
    }

    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP sent to your email';
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
      await apiService.registerRfid(_rfidController.text.trim(), _otpController.text.trim());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Register RFID Tag'),
        backgroundColor: teal,
      ),
      body: SingleChildScrollView(
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
                      'Link RFID Tag to Your Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // NFC Status
                    _buildNfcStatusBanner(),
                    SizedBox(height: 16),
                    
                    // Step 1: Request OTP
                    Text('Step 1: Request OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading || _otpSent ? null : _requestOtp,
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
                          : Text('Request OTP'),
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
                        hintText: 'Enter the OTP sent to your email',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: _otpSent,
                    ),
                    SizedBox(height: 16),
                    
                    // Step 3: Scan RFID
                    Text('Step 3: Scan RFID Tag', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _rfidController,
                      decoration: InputDecoration(
                        labelText: 'RFID UID',
                        border: OutlineInputBorder(),
                        hintText: _isNfcAvailable ? 'Hold an RFID tag near your device' : 'NFC not available',
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    
                    // Register button
                    ElevatedButton(
                      onPressed: _isLoading || !_otpSent ? null : _registerRfid,
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
                    Text('1. Click "Request OTP" to receive a verification code by email'),
                    Text('2. Enter the OTP you received in your email'),
                    Text('3. Hold your RFID tag near the back of your device'),
                    Text('4. Click "Register RFID" to link the tag to your account'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isNfcAvailable ? FloatingActionButton(
        onPressed: _restartNfcScan,
        backgroundColor: teal,
        child: Icon(_isScanning ? Icons.nfc : Icons.play_arrow),
        tooltip: _isScanning ? 'NFC Scanning Active' : 'Start NFC Scanning',
      ) : null,
    );
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
                  : 'NFC not available. Please use a device with NFC capabilities.',
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