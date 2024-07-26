import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreenSeller extends StatefulWidget {
  @override
  _OrdersScreenSellerState createState() => _OrdersScreenSellerState();
}

class _OrdersScreenSellerState extends State<OrdersScreenSeller> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<String?> fetchStoreId() async {
    try {
      print('Fetching store ID for user: $_userId');
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(_userId)
          .get();
      if (doc.exists) {
        print('Store ID fetched: ${doc.id}');
        return doc.id; // Store ID is the document ID
      } else {
        print('Store not found');
        return null;
      }
    } catch (e) {
      print('Error fetching store ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSellerOrders(String storeId) async {
    try {
      print('Fetching orders for store: $storeId');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isNotEqualTo: 'Delivered')
          .get();

      List<Map<String, dynamic>> orders = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var items = List<Map<String, dynamic>>.from(data['items'] ?? []);
        bool hasStoreId = items.any((item) => item['storeId'] == storeId);

        if (hasStoreId && data['status'] != 'Cancelled') {
          orders.add({
            'id': doc.id,
            'data': data,
          });
        }
      }

      print('Fetched orders count: ${orders.length}');
      return orders;
    } catch (e) {
      print('Error fetching seller orders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      print('Order status updated to $newStatus');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } catch (e) {
      print('Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status')),
      );
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
          'Current Orders',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<String?>(
        future: fetchStoreId(),
        builder: (context, storeIdSnapshot) {
          if (storeIdSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (storeIdSnapshot.hasError || !storeIdSnapshot.hasData) {
            print('Error or no data fetching store ID.');
            return Center(child: Text('Error fetching store ID.'));
          }

          var storeId = storeIdSnapshot.data;
          if (storeId == null) {
            return Center(child: Text('Store ID not found.'));
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchSellerOrders(storeId),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (ordersSnapshot.hasError) {
                print('Error fetching orders.');
                return Center(child: Text('Error fetching orders.'));
              } else if (!ordersSnapshot.hasData ||
                  ordersSnapshot.data!.isEmpty) {
                return Center(child: Text('No orders found.'));
              }

              var orders = ordersSnapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index]['data'];
                  var orderId = orders[index]['id'];
                  var items =
                      List<Map<String, dynamic>>.from(order['items'] ?? []);
                  var totalPrice = order['totalPrice'] ?? 0.0;
                  var deliveryCharge = order['deliveryCharge'] ?? 0.0;
                  var grandTotal = order['grandTotal'] ?? 0.0;
                  var name = order['name'] ?? '';
                  var address = order['address'] ?? '';
                  var phone = order['phone'] ?? '';
                  var email = order['email'] ?? '';
                  var notes = order['notes'] ?? '';
                  var timestamp = order['timestamp'] != null
                      ? (order['timestamp'] as Timestamp).toDate()
                      : null;
                  var status = order['status'] ??
                      'Pending'; // Default status if not present

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: $orderId',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 8.0),
                          ...items.map((item) {
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('items')
                                  .doc(item['productId'])
                                  .get(),
                              builder: (context, itemSnapshot) {
                                if (itemSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox.shrink();
                                } else if (itemSnapshot.hasError ||
                                    !itemSnapshot.hasData) {
                                  print(
                                      'Error fetching item data for product ID: ${item['productId']}');
                                  return SizedBox.shrink();
                                }

                                var product = itemSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                var imageUrl =
                                    (product['imageUrls'] as List<dynamic>?)
                                                ?.isNotEmpty ==
                                            true
                                        ? product['imageUrls'][0]
                                        : '';

                                return ListTile(
                                  contentPadding: EdgeInsets.all(8.0),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                  title: Text(product['name'] ?? 'Unknown'),
                                  subtitle: Text(
                                      'Size: ${item['size']} - Quantity: ${item['quantity']}'),
                                  trailing: Text(
                                      '\$${(product['price'] ?? 0) * (item['quantity'] ?? 0)}'),
                                );
                              },
                            );
                          }).toList(),
                          SizedBox(height: 8.0),
                          Text(
                            'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Delivery Charge: \$${deliveryCharge.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Grand Total: \$${grandTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Status: $status',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
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
                              'Ordered On: ${timestamp.toLocal()}',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          SizedBox(height: 8.0),
                          DropdownButton<String>(
                            value: status,
                            items: <String>[
                              'Pending',
                              'Processing',
                              'Shipped',
                              'Delivered',
                              'Cancelled'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newStatus) {
                              if (newStatus != null && newStatus != status) {
                                updateOrderStatus(orderId, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
