import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/core/receiver/services/donation_provider.dart';
import 'package:task7_food_savior_app/core/receiver/services/home_screen_provider.dart';
import 'package:task7_food_savior_app/core/receiver/widgets/drawer.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';
import 'package:task7_food_savior_app/utils/widgets/app_bar.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';

class RHomeScreen extends StatelessWidget {
  final User user;

  const RHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RHomeScreenProvider(user)),
        ChangeNotifierProvider(create: (_) => RDonationProvider()),
      ],
      child: const RHomeScreenBody(),
    );
  }
}

class RHomeScreenBody extends StatefulWidget {
  const RHomeScreenBody({super.key});

  @override
  State<RHomeScreenBody> createState() => _RHomeScreenBodyState();
}

class _RHomeScreenBodyState extends State<RHomeScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RDonationProvider>(context, listen: false).fetchDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenProvider = Provider.of<RHomeScreenProvider>(context);
    final donationProvider = Provider.of<RDonationProvider>(context);

    return Scaffold(
      backgroundColor: foregroundColor,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, screenProvider),
      body: _buildBody(context, donationProvider, screenProvider),
    );
  }

  Widget _buildBody(BuildContext context, RDonationProvider donationProvider,
      RHomeScreenProvider screenProvider) {
    if (donationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (donationProvider.error != null) {
      return Center(child: Text('Error: ${donationProvider.error}'));
    }

    if (donationProvider.donations.isEmpty) {
      return const Center(child: Text('No donations available.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: donationProvider.donations.length,
      itemBuilder: (context, index) {
        var donation = donationProvider.donations[index];
        return _buildDonationCard(context, donation, screenProvider);
      },
    );
  }

  Widget _buildDonationCard(BuildContext context,
      QueryDocumentSnapshot donation, RHomeScreenProvider provider) {
    final data = donation.data() as Map<String, dynamic>;
    return Card(
      color: dropColor,
      shadowColor: shadowColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['foodItems'] ?? 'Unnamed Donation',
              style: GoogleFonts.inter(
                  fontSize: 16.sp, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            4.height,
            Text(
              'Quantity: ${data['quantity']}',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            4.height,
            Text(
              'Pickup: ${_formatTimestamp(data['pickupTime'])}',
              style: GoogleFonts.inter(fontSize: 12.sp),
            ),
            4.height,
            Text(
              data['isAvailable'] ? 'Available' : 'Not Available',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: data['isAvailable'] ? Colors.green : Colors.red,
              ),
            ),
            10.height,
            Center(
              child: CustomButton(
                text: 'Schedule Pickup',
                onPressed: () =>
                    provider.schedulePickup(donation.id, data, context),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String date = DateFormat('dd MMM yyyy').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return '$date, $time';
  }
}
