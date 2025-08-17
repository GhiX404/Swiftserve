import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum NfcScanStatus {
  idle,
  scanning,
  success,
  error,
  notSupported
}

class NfcService {
  // Singleton pattern
  static final NfcService _instance = NfcService._internal();
  factory NfcService() => _instance;
  NfcService._internal();
  
  // Platform channel for NFC communication
  static const platform = MethodChannel('com.snuggy/nfc');
  
  // Stream controllers
  final _scanStatusController = StreamController<NfcScanStatus>.broadcast();
  final _tagUuidController = StreamController<String>.broadcast();
  
  // Stream getters
  Stream<NfcScanStatus> get scanStatusStream => _scanStatusController.stream;
  Stream<String> get tagUuidStream => _tagUuidController.stream;
  
  // Current status
  NfcScanStatus _currentStatus = NfcScanStatus.idle;
  NfcScanStatus get currentStatus => _currentStatus;
  
  // Scanning state
  bool _isScanning = false;
  bool _isNfcSupported = false;
  Timer? _scanTimer; // Only used in simulation mode
  
  // Start scanning for NFC tags
  Future<void> startScan() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _updateStatus(NfcScanStatus.scanning);
    
    if (kReleaseMode) {
      // Real NFC implementation for production
      try {
        await platform.invokeMethod('startNfcScan');
        // The actual UUID will be received via method channel callback
        _setupNfcCallbackHandler();
      } catch (e) {
        _updateStatus(NfcScanStatus.error);
        if (kDebugMode) {
          print('NFC scan error: $e');
        }
      }
    } else {
      // Simulate NFC scanning in development mode
      _simulateScan();
    }
  }
  
  // Stop scanning
  Future<void> stopScan() async {
    if (!_isScanning) return;
    
    _isScanning = false;
    
    if (kReleaseMode) {
      try {
        await platform.invokeMethod('stopNfcScan');
      } catch (e) {
        if (kDebugMode) {
          print('Error stopping NFC scan: $e');
        }
      }
    } else {
      _scanTimer?.cancel();
    }
    
    _updateStatus(NfcScanStatus.idle);
  }
  
  // Set up callback handler for NFC events from platform channel
  void _setupNfcCallbackHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNfcTagDetected':
          final uuid = call.arguments['uuid'] as String;
          _tagUuidController.add(uuid);
          _updateStatus(NfcScanStatus.success);
          break;
        case 'onNfcError':
          _updateStatus(NfcScanStatus.error);
          break;
        case 'onNfcNotSupported':
          _updateStatus(NfcScanStatus.notSupported);
          _isNfcSupported = false;
          break;
      }
    });
  }
  
  // Update scan status and notify listeners
  void _updateStatus(NfcScanStatus status) {
    _currentStatus = status;
    _scanStatusController.add(status);
  }
  
  // Simulate NFC scanning (for development only)
  void _simulateScan() {
    // Random delay between 1-3 seconds to simulate scanning time
    final scanDuration = Duration(milliseconds: 1000 + Random().nextInt(2000));
    
    _scanTimer = Timer(scanDuration, () {
      if (!_isScanning) return;
      
      // 90% chance of successful scan
      if (Random().nextDouble() < 0.9) {
        // Generate a mock UUID value
        final uuid = _generateMockUuid();
        _tagUuidController.add(uuid);
        _updateStatus(NfcScanStatus.success);
      } else {
        _updateStatus(NfcScanStatus.error);
      }
      
      // Reset status after a delay
      Timer(const Duration(seconds: 2), () {
        if (_isScanning) {
          _updateStatus(NfcScanStatus.scanning);
          _simulateScan(); // Continue scanning
        }
      });
    });
  }
  
  // Generate a mock UUID (for development only)
  String _generateMockUuid() {
    // Format: 8-4-4-4-12 hexadecimal digits
    const chars = '0123456789abcdef';
    final random = Random();
    
    String randomPart(int length) {
      return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
    }
    
    return '${randomPart(8)}-${randomPart(4)}-${randomPart(4)}-${randomPart(4)}-${randomPart(12)}';
  }
  
  // Check if device supports NFC
  Future<bool> checkNfcSupport() async {
    if (kReleaseMode) {
      try {
        _isNfcSupported = await platform.invokeMethod('isNfcSupported');
      } catch (e) {
        _isNfcSupported = false;
        if (kDebugMode) {
          print('Error checking NFC support: $e');
        }
      }
    } else {
      // Assume supported in development mode
      _isNfcSupported = true;
    }
    
    return _isNfcSupported;
  }
  
  // Initialize NFC hardware
  Future<bool> initializeHardware() async {
    if (kReleaseMode) {
      try {
        final result = await platform.invokeMethod('initializeNfc');
        _isNfcSupported = result;
        
        if (!_isNfcSupported) {
          _updateStatus(NfcScanStatus.notSupported);
        }
        
        return result;
      } catch (e) {
        _isNfcSupported = false;
        _updateStatus(NfcScanStatus.error);
        if (kDebugMode) {
          print('Error initializing NFC: $e');
        }
        return false;
      }
    } else {
      // Simulate initialization in development
      await Future.delayed(const Duration(milliseconds: 500));
      _isNfcSupported = true;
      return true;
    }
  }
  
  // Clean up resources
  void dispose() {
    stopScan();
    _scanStatusController.close();
    _tagUuidController.close();
  }
} 