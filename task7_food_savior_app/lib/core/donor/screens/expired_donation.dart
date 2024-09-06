import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/text.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';

class ExpiredDonationsScreen extends StatelessWidget {
  const ExpiredDonationsScreen({super.key});

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foregroundColor,
      appBar: AppBar(
        title: Text(
          'Expired Donations',
          style: appBarStyle,
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: iconTheme),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expiredDonations')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No expired donations available.'));
          }

          final expiredDonations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: expiredDonations.length,
            itemBuilder: (context, index) {
              var donation =
                  expiredDonations[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                color: dropColor,
                shadowColor: shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation['foodItems'] ?? 'Unnamed Donation',
                        style: donationNameStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.height,
                      Text(
                        'Quantity: ${donation['quantity']}',
                        style: donationLabelStyle,
                      ),
                      4.height,
                      Text(
                        'Pickup Time: ${_formatTimestamp(donation['pickupTime'])}',
                        style: donationLabelStyle,
                      ),
                      8.height,
                      Text(
                        'Donation Details:',
                        style: donationDetailStyle,
                      ),
                      4.height,
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.info_outline,
                            color: primaryColor,
                          ),
                          title: Text(
                            'Donor ID: ${donation['userId']}',
                            style: donationLabelStyle,
                          ),
                          subtitle: Text(
                              'Created At: ${_formatTimestamp(donation['createdAt'])}',
                              style: donationColorStyle),
                        ),
                      ),
                      Text('Status: Expired', style: donationColorStyle),
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
}
