import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double amount;

  const PaymentScreen({super.key, required this.orderId, required this.amount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);

  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';
  bool _isProcessing = false;
  String? _error;

  final ApiService _apiService = ApiService();

  // Format card number in groups of 4 digits
  String _formatCardNumber(String value) {
    if (value.isEmpty) return '';
    
    value = value.replaceAll(RegExp(r'\D'), '');
    final result = StringBuffer();
    
    for (int i = 0; i < value.length; i += 4) {
      int end = i + 4;
      if (end > value.length) end = value.length;
      result.write(value.substring(i, end));
      if (end < value.length) result.write(' ');
    }
    
    return result.toString();
  }

  // Expiry date formatter (MM/YY)
  String _formatExpiryDate(String value) {
    if (value.isEmpty) return '';
    
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length > 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    
    try {
      // In a real app, we would securely process the payment here
      // For this demo, we'll just simulate success after a delay
      // TODO: Backend does not support a generic `processPayment` call.
      // This needs to be implemented with a proper payment gateway integration
      // and backend endpoints (e.g., /orders/{id}/pay/card).
      // await _apiService.processPayment(
      //   widget.orderId.toString(),
      //   'card',
      // );
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isProcessing = false;
      });
      
      // Show success and navigate to orders page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful! Order confirmed.')),
      );
      
      // Small delay before navigating away
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, '/orders');
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = 'Payment failed: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: teal,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with amount
            Container(
              width: double.infinity,
              color: teal,
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Payment Form
            Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: teal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Error message if any
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Card holder name
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Card Holder Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.person, color: teal),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: teal),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card holder name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _cardHolderName = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Card number
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.credit_card, color: teal),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: teal),
                        ),
                        hintText: '1234 5678 9012 3456',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card number';
                        }
                        final cardNum = value.replaceAll(' ', '');
                        if (cardNum.length != 16) {
                          return 'Card number must be 16 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _cardNumber = _formatCardNumber(value);
                        });
                      },
                      controller: TextEditingController(text: _cardNumber)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: _cardNumber.length),
                        ),
                      onSaved: (value) {
                        _cardNumber = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Expiry and CVV row
                    Row(
                      children: [
                        // Expiry Date
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.date_range, color: teal),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: teal),
                              ),
                              hintText: 'MM/YY',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final cleanValue = value.replaceAll('/', '');
                              if (cleanValue.length != 4) {
                                return 'Invalid format';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _expiryDate = _formatExpiryDate(value);
                              });
                            },
                            controller: TextEditingController(text: _expiryDate)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: _expiryDate.length),
                              ),
                            onSaved: (value) {
                              _expiryDate = value!;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // CVV
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: teal),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: teal),
                              ),
                              hintText: '123',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length != 3) {
                                return 'Invalid CVV';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _cvv = value!;
                            },
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Pay button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isProcessing ? null : _processPayment,
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Pay ₹${widget.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Security message
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Your payment information is secure',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 