import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_6_e_commerce_app/models/storeModel.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreModel store;

  StoreDetailScreen({required this.store});

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(color: Colors.red, fontSize: 16),
                    ),
                  );
                },
              ),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
                borderRadius: BorderRadius.circular(12.0),
                child: GestureDetector(
                  onTap: () {
                    if (store.image.isNotEmpty) {
                      _showFullImage(context, store.image);
                    }
                  },
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
                                'Failed to load image',
                                style: GoogleFonts.inter(
                                    color: Colors.red, fontSize: 16),
                              ),
                            );
                          },
                        )
                      : Center(child: Text('No image available')),
                ),
              ),
              SizedBox(height: 16.0),

              // Store Name
              Text(
                'Store Name',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                store.storeName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16.0),

              // Description
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                store.description,
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 16.0),

              // Address
              Text(
                'Address',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                store.address,
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 16.0),

              // Email
              Text(
                'Email',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                store.email,
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 16.0),

              // Phone
              Text(
                'Phone',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                store.phone,
                style: GoogleFonts.inter(fontSize: 16),
              ),
              SizedBox(height: 16.0),

              // Active Status
              Text(
                'Active Status',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                store.isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: store.isActive ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
