import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> selectedItems;

  CheckoutScreen({required this.selectedItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Map<String, dynamic>>> _items;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController(); // Optional notes field
  String? _userId;

  @override
  void initState() {
    super.initState();
    _items = widget.selectedItems;
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose(); // Dispose the notes controller
    super.dispose();
  }

  Future<void> addOrderToFirestore(Map<String, dynamic> orderData) async {
    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);
    } catch (e) {
      print('Error adding order to Firestore: $e');
      // Handle error
    }
  }

  Future<void> updateInventory(List<Map<String, dynamic>> items) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var item in items) {
        DocumentReference itemRef = FirebaseFirestore.instance
            .collection('items')
            .doc(item['productId']);

        // Decrease the quantity for the selected size
        batch.update(itemRef,
            {'sizes.${item['size']}': FieldValue.increment(-item['quantity'])});
      }

      await batch.commit();
    } catch (e) {
      print('Error updating inventory: $e');
      // Handle error
    }
  }

  Future<void> clearOrderedItemsFromCart(
      List<Map<String, dynamic>> orderedItems) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var item in orderedItems) {
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection('carts')
            .where('userId', isEqualTo: _userId)
            .where('productId', isEqualTo: item['productId'])
            .where('size', isEqualTo: item['size'])
            .limit(1)
            .get();

        if (cartSnapshot.docs.isNotEmpty) {
          batch.delete(cartSnapshot.docs.first.reference);
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing ordered items from cart: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Checkout',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('No items selected.'));
          }

          var items = snapshot.data!;
          Map<String, List<Map<String, dynamic>>> storeGroupedItems = {};

          // Group items by store
          for (var item in items) {
            String storeId = item['storeName'];
            if (!storeGroupedItems.containsKey(storeId)) {
              storeGroupedItems[storeId] = [];
            }
            storeGroupedItems[storeId]!.add(item);
          }

          double totalPrice = items.fold(
              0,
              (sum, item) =>
                  sum + (item['product']['price'] * item['quantity']));
          double totalDeliveryCharges =
              storeGroupedItems.length * 5.0; // $5 per store
          double grandTotal = totalPrice + totalDeliveryCharges;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: GoogleFonts.inter(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...storeGroupedItems.entries.map((entry) {
                    String storeId = entry.key;
                    List<Map<String, dynamic>> storeItems = entry.value;
                    double storeTotalPrice = storeItems.fold(
                        0,
                        (sum, item) =>
                            sum +
                            (item['product']['price'] * item['quantity']));
                    double storeDeliveryCharge = 5.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store ${storeId}', // You may want to use a store name instead
                          style: GoogleFonts.inter(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        ...storeItems.map((item) {
                          var product = item['product'];
                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4.0,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12.0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  product['imageUrls'][0],
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              title: Text(product['name']),
                              subtitle: Text(
                                  'Size: ${item['size']} - Quantity: ${item['quantity']}'),
                              trailing: Text(
                                  '\$${product['price'] * item['quantity']}'),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 8.0),
                        Text(
                          'Total Price for Store ${storeId}: \$${storeTotalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Delivery Charge for Store ${storeId}: \$${storeDeliveryCharge.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  Text(
                    'Grand Total (including delivery charges): \$${grandTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Payment Method: Cash on Delivery (COD)',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextFormField(
                          controller: _nameController,
                          labelText: 'Name',
                          icon: Icons.person,
                        ),
                        SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _addressController,
                          labelText: 'Address',
                          icon: Icons.home,
                        ),
                        SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _notesController,
                          labelText: 'Notes (optional)',
                          icon: Icons.note,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Ensure _userId is not null
                              if (_userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('User not logged in.')),
                                );
                                return;
                              }

                              // Prepare order data
                              Map<String, dynamic> orderData = {
                                'userId': _userId,
                                'items': items
                                    .map((item) => {
                                          'productId': item['productId'],
                                          'quantity': item['quantity'],
                                          'size': item['size'],
                                          'storeId': item['storeId'],
                                        })
                                    .toList(),
                                'totalPrice': totalPrice,
                                'deliveryCharge': totalDeliveryCharges,
                                'grandTotal': grandTotal,
                                'name': _nameController.text,
                                'address': _addressController.text,
                                'phone': _phoneController.text,
                                'email': _emailController.text,
                                'notes': _notesController.text,
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': 'Pending',
                              };

                              // Add order to Firestore
                              await addOrderToFirestore(orderData);

                              // Update inventory
                              await updateInventory(items);

                              // Clear ordered items from cart
                              await clearOrderedItemsFromCart(items);

                              // Show success message and navigate back
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Order placed successfully!')),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Confirm Order',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }
}
