import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>?> _productDetails;
  String? _selectedSize;
  int _selectedQuantity = 1;
  final _auth = FirebaseAuth.instance;
  late Future<String> _storeName;

  @override
  void initState() {
    super.initState();
    _productDetails = _fetchProductDetails();
    _storeName = _fetchStoreName();
  }

  Future<Map<String, dynamic>?> _fetchProductDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.productId)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching product details: $e');
      return null;
    }
  }

  Future<String> _fetchStoreId() async {
    try {
      var productDetails = await _fetchProductDetails();
      if (productDetails == null) return '';

      return productDetails['storeId'] as String? ?? '';
    } catch (e) {
      print('Error fetching storeId: $e');
      return '';
    }
  }

  Future<String> _fetchStoreName() async {
    try {
      var storeId = await _fetchStoreId();
      if (storeId.isEmpty) return 'Unknown Store';

      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get();

      var storeData = storeDoc.data() as Map<String, dynamic>?;
      return storeData?['storeName'] ?? 'Unknown Store';
    } catch (e) {
      print('Error fetching store name: $e');
      return 'Unknown Store';
    }
  }

  Future<void> _addToCart() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _selectedSize != null) {
        String storeId = await _fetchStoreId();
        String storeName = await _fetchStoreName();

        await FirebaseFirestore.instance.collection('carts').add({
          'userId': user.uid,
          'productId': widget.productId,
          'size': _selectedSize,
          'quantity': _selectedQuantity,
          'storeId': storeId,
          'storeName': storeName,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to cart!')),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart.')),
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
        title: Text('Product Details',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _productDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading product details'));
          }

          var product = snapshot.data!;
          List<dynamic> sizes;
          if (product['sizes'] is Map) {
            sizes = (product['sizes'] as Map).keys.toList();
          } else if (product['sizes'] is List) {
            sizes = product['sizes'];
          } else {
            sizes = [];
          }

          return FutureBuilder<String>(
            future: _storeName,
            builder: (context, storeSnapshot) {
              if (storeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (storeSnapshot.hasError || !storeSnapshot.hasData) {
                return Center(child: Text('Error loading store name'));
              }

              var storeName = storeSnapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageCarousel(product['imageUrls']),
                      SizedBox(height: 16.0),
                      Text(
                        product['name'],
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '\$${product['price'].toString()}',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Category: ${product['category']}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Store: $storeName',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Available Sizes:',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        children: sizes.map((size) {
                          return ChoiceChip(
                            label: Text(
                              size.toString(),
                              style: GoogleFonts.inter(
                                color: _selectedSize == size.toString()
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: _selectedSize == size.toString(),
                            selectedColor: Colors.black,
                            backgroundColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSize =
                                    selected ? size.toString() : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Quantity:',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (_selectedQuantity > 1) {
                                setState(() {
                                  _selectedQuantity--;
                                });
                              }
                            },
                          ),
                          Text(
                            _selectedQuantity.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _selectedQuantity++;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _selectedSize != null
                            ? () {
                                _addToCart();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart),
                            SizedBox(width: 8.0),
                            Text('Add to Cart'),
                          ],
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

  Widget _buildImageCarousel(List<dynamic> imageUrls) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenImageScreen(imageUrl: imageUrls[index]),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: imageUrl,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
