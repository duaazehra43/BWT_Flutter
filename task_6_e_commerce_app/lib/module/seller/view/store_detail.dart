import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_6_e_commerce_app/module/seller/view/create_store.dart';
import 'edit_store.dart'; // Import the EditStoreScreen

class StoreDetailScreen extends StatefulWidget {
  final String userId;

  StoreDetailScreen({required this.userId});

  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  Map<String, dynamic>? storeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    try {
      DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.userId)
          .get();
      if (storeSnapshot.exists) {
        setState(() {
          storeData = storeSnapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching store details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deleteStore() async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.userId)
          .delete();
      Navigator.of(context).pop(); // Go back after deletion
    } catch (e) {
      print('Error deleting store: $e');
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Store'),
        content: Text('Are you sure you want to delete this store?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteStore();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          storeData?['storeName'] ?? 'Store Details',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditStoreScreen(widget.userId),
                  ),
                ).then((_) {
                  _fetchStoreDetails(); // Refresh store details after editing
                });
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : storeData == null || storeData!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No store details found.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'It looks like your store is not set up yet. Please set up your store to see the details.',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateStoreScreen(widget.userId),
                            ),
                          ).then((_) {
                            _fetchStoreDetails();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white),
                        child: Text(
                          'Set Up Store',
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      if (storeData?['image'] != null)
                        Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  storeData!['image'],
                                  height: 150,
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                storeData?['description'] ?? '',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Contact Information',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.email),
                                  SizedBox(width: 10),
                                  Text(
                                    storeData?['email'] ?? '',
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.phone),
                                  SizedBox(width: 10),
                                  Text(
                                    storeData?['phone'] ?? '',
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      storeData?['address'] ?? '',
                                      style: GoogleFonts.inter(fontSize: 16),
                                    ),
                                  ),
                                ],
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
