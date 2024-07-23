import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      print('Fetching orders for user: $_userId');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .get();

      print('Fetched orders count: ${querySnapshot.docs.length}');
      return querySnapshot.docs
          .map((doc) =>
              {'id': doc.id, 'data': doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('items')
          .doc(productId)
          .get();
      return docSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching product details: $e');
      return null;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Cancelled'});
      print('Order cancelled successfully.');
      // Optionally, show a snackbar or some other notification
    } catch (e) {
      print('Error cancelling order: $e');
      // Handle the error as needed
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
          'My Orders',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching orders.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          var orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index]['data'] as Map<String, dynamic>?;
              var items =
                  List<Map<String, dynamic>>.from(order?['items'] ?? []);
              var totalPrice = order?['totalPrice'] ?? 0.0;
              var deliveryCharge = order?['deliveryCharge'] ?? 0.0;
              var grandTotal = order?['grandTotal'] ?? 0.0;
              var name = order?['name'] ?? 'Unknown';
              var address = order?['address'] ?? 'Unknown';
              var phone = order?['phone'] ?? 'Unknown';
              var email = order?['email'] ?? 'Unknown';
              var notes = order?['notes'] ?? '';
              var timestamp = order?['timestamp'] != null
                  ? (order?['timestamp'] as Timestamp).toDate()
                  : null;
              var status = order?['status'] ?? 'Pending'; // Default status

              return Card(
                color: Colors.white,
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: Future.wait(
                          items.map((item) async {
                            var productDetails =
                                await fetchProductDetails(item['productId']);
                            return {
                              'product': productDetails,
                              'size': item['size'],
                              'quantity': item['quantity']
                            };
                          }).toList(),
                        ),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (productSnapshot.hasError) {
                            return Center(
                                child: Text('Error fetching product details.'));
                          } else if (!productSnapshot.hasData ||
                              productSnapshot.data!.isEmpty) {
                            return Center(
                                child: Text('No product details found.'));
                          }

                          var products = productSnapshot.data!;
                          return Column(
                            children: products.map((productItem) {
                              var product = productItem['product']
                                  as Map<String, dynamic>?;
                              var productName =
                                  product?['name'] ?? 'Unknown Product';
                              var productImageUrls =
                                  product?['imageUrls'] as List<dynamic>? ?? [];
                              var productImageUrl = productImageUrls.isNotEmpty
                                  ? productImageUrls[0]
                                  : null;
                              var productPrice = product?['price'] ?? 0.0;
                              var size = productItem['size'] ?? 'Unknown';
                              var quantity = productItem['quantity'] ?? 0;
                              return ListTile(
                                contentPadding: EdgeInsets.all(8.0),
                                leading: productImageUrl != null
                                    ? Image.network(
                                        productImageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                title: Text(
                                  productName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Size: $size - Quantity: $quantity',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Text(
                                  '\$${(productPrice * quantity).toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      Divider(),
                      Text(
                        'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Delivery Charge: \$${deliveryCharge.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Grand Total: \$${grandTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Name: $name',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      Text(
                        'Address: $address',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      Text(
                        'Phone: $phone',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      Text(
                        'Email: $email',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      if (notes.isNotEmpty)
                        Text(
                          'Notes: $notes',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      if (timestamp != null)
                        Text(
                          'Ordered On: ${DateFormat.yMMMd().add_jm().format(timestamp)}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      SizedBox(height: 8.0),
                      Text(
                        'Status: $status',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      if (status == 'Pending')
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await cancelOrder(orders[index]['id']);
                              setState(() {}); // Refresh the UI
                            },
                            child: Text('Cancel Order'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
