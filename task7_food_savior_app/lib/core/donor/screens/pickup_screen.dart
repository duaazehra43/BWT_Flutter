import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';

class DonorPickupScreen extends StatelessWidget {
  final User user;

  const DonorPickupScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Pickups'),
        backgroundColor: primaryColor,
        foregroundColor: foregroundColor,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('scheduledPickups')
            .where('userId', isEqualTo: user.uid) // Filter by the current donor
            .get(),
        builder: (context, pickupSnapshot) {
          if (pickupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pickupSnapshot.hasError) {
            return Center(child: Text('Error: ${pickupSnapshot.error}'));
          }

          if (!pickupSnapshot.hasData || pickupSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No scheduled pickups.'));
          }

          final pickups = pickupSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: pickups.length,
            itemBuilder: (context, index) {
              var pickup = pickups[index].data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('donations')
                    .doc(pickup['donationId'])
                    .get(),
                builder: (context, donationSnapshot) {
                  if (donationSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  if (donationSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${donationSnapshot.error}'));
                  }

                  if (!donationSnapshot.hasData ||
                      donationSnapshot.data == null) {
                    return const ListTile(
                      title: Text('Donation not found'),
                    );
                  }

                  var donationData =
                      donationSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donationData['foodItems'] ?? 'Unnamed Donation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Quantity: ${donationData['quantity']}',
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Pickup Time: ${_formatTimestamp(pickup['pickupTime'])}',
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Receiver:',
                          ),
                          const SizedBox(height: 4.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.person,
                                color: primaryColor,
                              ),
                              title:
                                  Text('Receiver ID: ${pickup['receiverId']}'),
                              subtitle: Text(
                                'Scheduled At: ${_formatTimestamp(pickup['scheduledAt'])}',
                                style: TextStyle(
                                  color: pickup['status'] == 'Completed'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
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
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, h:mm a').format(dateTime);
  }
}
