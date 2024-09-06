import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/text.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';

class DonorPickupScreen extends StatelessWidget {
  final User user;

  const DonorPickupScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scheduled Pickups',
          style: appBarStyle,
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: iconTheme),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scheduledPickups')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
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

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('donations')
                    .doc(pickup['donationId'])
                    .snapshots(),
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
                            style: donationNameStyle,
                          ),
                          8.height,
                          Text(
                            'Quantity: ${donationData['quantity']}',
                            style: donationLabelStyle,
                          ),
                          4.height,
                          Text(
                            'Pickup Time: ${_formatTimestamp(pickup['pickupTime'])}',
                          ),
                          8.height,
                          Text(
                            'Receiver:',
                            style: labelStyle,
                          ),
                          4.height,
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
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
