import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_6_e_commerce_app/module/buyer/checkout.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _auth = FirebaseAuth.instance;
  late Future<List<Map<String, dynamic>>> _cartItems;
  Map<String, bool> storeSelection = {}; // Track selected stores
  Set<String> selectedItems = {}; // Track selected item IDs

  @override
  void initState() {
    super.initState();
    _cartItems = _fetchCartItems();
  }

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection('carts')
            .where('userId', isEqualTo: user.uid)
            .get();

        List<Map<String, dynamic>> items = [];
        for (var doc in cartSnapshot.docs) {
          DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
              .collection('items')
              .doc(doc['productId'])
              .get();
          DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
              .collection('stores')
              .doc(productSnapshot['storeId'])
              .get();

          items.add({
            'cartId': doc.id,
            'productId': doc['productId'],
            'size': doc['size'],
            'quantity': doc['quantity'],
            'product': productSnapshot.data(),
            'storeId': productSnapshot['storeId'],
            'storeName': storeSnapshot['storeName'],
          });
        }
        return items;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  Future<void> _removeFromCart(String cartId) async {
    try {
      await FirebaseFirestore.instance.collection('carts').doc(cartId).delete();
      setState(() {
        _cartItems = _fetchCartItems();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from cart!')),
      );
    } catch (e) {
      print('Error removing from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from cart.')),
      );
    }
  }

  Future<void> _updateQuantity(String cartId, int newQuantity) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(cartId)
          .update({'quantity': newQuantity});
      setState(() {
        _cartItems = _fetchCartItems();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity updated!')),
      );
    } catch (e) {
      print('Error updating quantity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity.')),
      );
    }
  }

  void _toggleStoreSelection(String storeId) {
    setState(() {
      storeSelection[storeId] = !(storeSelection[storeId] ?? false);
    });
  }

  void _toggleItemSelection(String cartId) {
    setState(() {
      if (selectedItems.contains(cartId)) {
        selectedItems.remove(cartId);
      } else {
        selectedItems.add(cartId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'My Cart',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('No items in cart.'));
          }

          var items = snapshot.data!;
          Map<String, List<Map<String, dynamic>>> storeGroupedItems = {};

          // Group items by store
          for (var item in items) {
            String storeId = item['storeId'];
            if (!storeGroupedItems.containsKey(storeId)) {
              storeGroupedItems[storeId] = [];
            }
            storeGroupedItems[storeId]!.add(item);
          }

          return ListView(
            children: storeGroupedItems.entries.map((entry) {
              String storeId = entry.key;
              List<Map<String, dynamic>> products = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          products.isNotEmpty
                              ? products[0]['storeName']
                              : 'Unknown Store',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Checkbox(
                          value: storeSelection[storeId] ?? false,
                          onChanged: (value) {
                            if (value != null) {
                              _toggleStoreSelection(storeId);
                              if (value) {
                                for (var product in products) {
                                  selectedItems.add(product['cartId']);
                                }
                              } else {
                                for (var product in products) {
                                  selectedItems.remove(product['cartId']);
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  ...products.map((item) {
                    var product = item['product'];
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            product['imageUrls'][0],
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        ),
                        title: Text(
                          product['name'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Size: ${item['size']}',
                              style: GoogleFonts.inter(),
                            ),
                            Text(
                              '\$${product['price']}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Quantity: ',
                                  style: GoogleFonts.inter(),
                                ),
                                DropdownButton<int>(
                                  dropdownColor: Colors.white,
                                  value: item['quantity'],
                                  items: List.generate(10, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index + 1,
                                      child: Text('${index + 1}'),
                                    );
                                  }),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _updateQuantity(item['cartId'], value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _removeFromCart(item['cartId']);
                              },
                            ),
                            Checkbox(
                              value: selectedItems.contains(item['cartId']),
                              onChanged: (value) {
                                if (value != null) {
                                  _toggleItemSelection(item['cartId']);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: 120,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Pass selected items to CheckoutScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(
                    selectedItems: _cartItems.then((items) => items
                        .where((item) => selectedItems.contains(item['cartId']))
                        .toList()),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.0),
              textStyle: GoogleFonts.inter(
                fontSize: 18,
              ),
            ),
            child: Text('Proceed to Checkout'),
          ),
        ),
      ),
    );
  }
}
