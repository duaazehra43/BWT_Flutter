import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task7_food_savior_app/core/donor/screens/edit_donation.dart';
import 'package:task7_food_savior_app/core/donor/services/donation_provider.dart';
import 'package:task7_food_savior_app/core/donor/services/home_screen_service.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/text.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';

Widget buildDonationList(
    DonationProvider donationProvider, HomeScreenViewModel viewModel) {
  if (donationProvider.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (donationProvider.error != null) {
    return Center(child: Text('Error: ${donationProvider.error}'));
  }

  if (donationProvider.donations.isEmpty) {
    return const Center(child: Text('No donations available.'));
  }

  return GridView.builder(
    padding: EdgeInsets.all(16.w),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      childAspectRatio: 2.0,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
    ),
    itemCount: donationProvider.donations.length,
    itemBuilder: (context, index) {
      var donation = donationProvider.donations[index];
      return _buildDonationCard(donation, context, viewModel);
    },
  );
}

Widget _buildDonationCard(QueryDocumentSnapshot donation, BuildContext context,
    HomeScreenViewModel viewModel) {
  return Card(
    color: dropColor,
    shadowColor: shadowColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                donation['foodItems'] ?? 'Unnamed Donation',
                style: donationNameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              4.height,
              Text(
                'Quantity: ${donation['quantity']}',
                style: donationLabelStyle,
              ),
              4.height,
              Text(
                'Pickup: ${viewModel.formatTimestamp(donation['pickupTime'])}',
                style: donationLabelStyle,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(right: 8.0.w, bottom: 8.0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () =>
                    _editDonation(context, viewModel.user, donation.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => viewModel.deleteDonation(donation.id),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _editDonation(BuildContext context, User user, String donationId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          EditDonationScreen(user: user, donationId: donationId),
    ),
  );
}
