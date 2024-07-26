import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_6_e_commerce_app/LoginScreen.dart';
import 'package:task_6_e_commerce_app/module/admin/view/store_detail.dart';
import 'package:task_6_e_commerce_app/module/admin/view_model/admin_view_model.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminViewModel()..fetchStores(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text(
            'Admin - Manage Stores',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              },
            ),
          ],
        ),
        body: Consumer<AdminViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (viewModel.hasError) {
              return Center(child: Text('Error fetching stores.'));
            } else if (viewModel.stores.isEmpty) {
              return Center(child: Text('No stores found.'));
            }

            var stores = viewModel.stores;
            return ListView.builder(
              itemCount: stores.length,
              itemBuilder: (context, index) {
                var store = stores[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreDetailScreen(store: store),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store ID: ${store.id}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Store Name: ${store.storeName}',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          Text(
                            'Active: ${store.isActive ? 'Yes' : 'No'}',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          Text(
                            'Banned: ${store.isBanned ? 'Yes' : 'No'}',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (!store.isActive && !store.isBanned) {
                                    viewModel.updateStoreStatus(store.id, true);
                                  }
                                },
                                child: Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              if (!store
                                  .isActive) // Show Reject button only if the store is not active
                                ElevatedButton(
                                  onPressed: () {
                                    print('Reject button pressed');
                                    if (!store.isActive && !store.isBanned) {
                                      viewModel.updateStoreStatus(
                                          store.id, false);
                                    }
                                  },
                                  child: Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  if (store.isActive && !store.isBanned) {
                                    viewModel.banStore(store.id, true);
                                  } else if (store.isBanned) {
                                    viewModel.banStore(store.id, false);
                                  }
                                },
                                child: Text(store.isBanned ? 'Unban' : 'Ban'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: store.isBanned
                                      ? Colors.orange
                                      : Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
