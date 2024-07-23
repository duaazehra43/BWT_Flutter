import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_6_e_commerce_app/models/storeModel.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreModel store;

  StoreDetailScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Store Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: store.image.isNotEmpty
                    ? Image.network(
                        store.image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Failed to load image: $error',
                              style: GoogleFonts.inter(
                                  color: Colors.red, fontSize: 16),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('No image available')),
              ),
              SizedBox(height: 16.0),

              // Store Name
              Text(
                'Store Name: ${store.storeName}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8.0),

              // Description
              Text(
                'Description: ${store.description}',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 8.0),

              // Address
              Text(
                'Address: ${store.address}',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 8.0),

              // Email
              Text(
                'Email: ${store.email}',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 8.0),

              // Phone
              Text(
                'Phone: ${store.phone}',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 8.0),

              // Active Status
              Text(
                'Active: ${store.isActive ? 'Yes' : 'No'}',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
