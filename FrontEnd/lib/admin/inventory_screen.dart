import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  List<InventoryItem> _inventoryItems = [];
  String? _error;
  
  final TextEditingController _searchController = TextEditingController();
  List<InventoryItem> _filteredItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadInventory();
    
    _searchController.addListener(() {
      _filterItems();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_inventoryItems);
      } else {
        _filteredItems = _inventoryItems
            .where((item) => 
                item.name.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query))
            .toList();
      }
    });
  }
  
  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // TODO: Implement backend endpoint for getting inventory
      // final items = await _apiService.getInventory();
      // setState(() {
      //   _inventoryItems = items;
      //   _filteredItems = List.from(items);
      // });
    } catch (e) {
      setState(() {
        _error = 'Failed to load inventory: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateInventoryItem(InventoryItem item, int newQuantity) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implement backend endpoint for updating inventory
      // await _apiService.updateInventoryItem(item.id.toString(), {'quantity': newQuantity});
      await _loadInventory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} quantity updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update inventory: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController = TextEditingController();
    final thresholdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: thresholdController,
                decoration: const InputDecoration(
                  labelText: 'Alert Threshold',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  thresholdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }
              
              try {
                final quantity = int.parse(quantityController.text);
                final threshold = int.parse(thresholdController.text);
                
                final newItem = {
                  'name': nameController.text,
                  'category': categoryController.text,
                  'quantity': quantity,
                  'alertThreshold': threshold,
                };

                // TODO: Implement backend endpoint for adding inventory
                // await _apiService.addInventoryItem(newItem);
                
                Navigator.pop(context);
                await _loadInventory();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add item: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showUpdateQuantityDialog(InventoryItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${item.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'New Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final newQuantity = int.parse(quantityController.text);
                Navigator.pop(context);
                _updateInventoryItem(item, newQuantity);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: teal,
        title: const Text('Inventory Management', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInventory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: teal,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search inventory items...',
                prefixIcon: Icon(Icons.search, color: teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Inventory categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All', true),
                _buildCategoryChip('Vegetables', false),
                _buildCategoryChip('Fruits', false),
                _buildCategoryChip('Dairy', false),
                _buildCategoryChip('Grains', false),
                _buildCategoryChip('Spices', false),
              ],
            ),
          ),
          
          // Inventory list
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
                              onPressed: _loadInventory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teal,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No inventory items found',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isLowStock = item.quantity <= item.alertThreshold;
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(item.category).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: _getCategoryColor(item.category),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text('Category: ${item.category}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Quantity: ${item.quantity}',
                                            style: TextStyle(
                                              color: isLowStock ? Colors.red : null,
                                              fontWeight: isLowStock ? FontWeight.bold : null,
                                            ),
                                          ),
                                          if (isLowStock) ...[
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            const Text(
                                              'Low Stock',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit, color: teal),
                                    onPressed: () => _showUpdateQuantityDialog(item),
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
  
  Widget _buildCategoryChip(String category, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          // Implement category filtering
        },
        backgroundColor: Colors.white,
        selectedColor: teal.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? teal : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: teal,
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Colors.green;
      case 'fruits':
        return Colors.orange;
      case 'dairy':
        return Colors.blue;
      case 'grains':
        return Colors.amber;
      case 'spices':
        return Colors.red;
      default:
        return teal;
    }
  }
} 