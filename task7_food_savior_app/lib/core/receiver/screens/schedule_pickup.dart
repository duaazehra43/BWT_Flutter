import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';

class ScheduledPickupScreen extends StatelessWidget {
  final User user;

  const ScheduledPickupScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Pickups'),
        backgroundColor: primaryColor,
        foregroundColor: foregroundColor,
        iconTheme: const IconThemeData(color: iconTheme),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scheduledPickups')
            .where('receiverId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No scheduled pickups.'));
          }

          final pickups = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: pickups.length,
            itemBuilder: (context, index) {
              var pickup = pickups[index].data() as Map<String, dynamic>;
              return _buildPickupCard(pickup);
            },
          );
        },
      ),
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> pickup) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .doc(pickup['donationId'])
          .snapshots(),
      builder: (context, donationSnapshot) {
        if (!donationSnapshot.hasData || donationSnapshot.data == null) {
          return const Center(
            child: ListTile(
              title: Text('Donation not found'),
            ),
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
                Row(
                  children: [
                    const Icon(
                      Icons.food_bank,
                      color: primaryColor,
                      size: 40.0,
                    ),
                    16.width,
                    Expanded(
                      child: Text(
                        donationData['foodItems'] ?? 'Unnamed Donation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                8.height,
                Text('Quantity: ${donationData['quantity']}'),
                4.height,
                Text(
                    'Pickup Time: ${_formatTimestamp(donationData['pickupTime'])}'),
                4.height,
                Text(
                    'Scheduled At: ${_formatTimestamp(pickup['scheduledAt'])}'),
                4.height,
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, h:mm a').format(dateTime);
  }
}
