import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/core/receiver/services/donation_provider.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/extensions/scaffold.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';

class RHomeScreen extends StatefulWidget {
  final User user;

  const RHomeScreen({super.key, required this.user});

  @override
  _RHomeScreenState createState() => _RHomeScreenState();
}

class _RHomeScreenState extends State<RHomeScreen> {
  String? userName;
  String? userEmail;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RDonationProvider>(context, listen: false).fetchDonations();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          userEmail = userDoc['email'];
          userRole = userDoc['role'];
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String date = DateFormat('dd MMM yyyy').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return '$date, $time';
  }

  Future<void> _schedulePickup(
      String donationId, Map<String, dynamic> donationData) async {
    final success = await Provider.of<RDonationProvider>(context, listen: false)
        .schedulePickup(donationId, widget.user.uid, donationData);

    if (success) {
      context.showSnackBar('Pickup scheduled successfully');
      await Provider.of<RDonationProvider>(context, listen: false)
          .fetchDonations();
    } else {
      context.showSnackBar('Failed to schedule pickup');
    }
  }

  void _schedule() {
    context.push('/schedule', extra: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foregroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: AppBar(
          title: Text(
            'Food Savior',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(
            color: iconTheme,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.r),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.h),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
              child: Center(
                child: Container(
                  height: 36.h,
                  width: 300.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 3.h),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: foregroundColor,
                    radius: 30.r,
                    child: Text(
                      userName?.isNotEmpty == true ? userName![0] : '',
                      style:
                          GoogleFonts.inter(fontSize: 30.sp, color: textColor),
                    ),
                  ),
                  10.height,
                  Text(
                    userName ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      color: foregroundColor,
                    ),
                  ),
                  Text(
                    userEmail ?? '',
                    style: GoogleFonts.inter(
                      color: foregroundColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (userRole != null)
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(userRole!),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Scheduled Pickup'),
              onTap: _schedule,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Consumer<RDonationProvider>(
        builder: (context, donationProvider, child) {
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
                        donation['foodItems'] ?? 'Unnamed Donation',
                        style: GoogleFonts.inter(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Text(
                        'Quantity: ${donation['quantity']}',
                        style: GoogleFonts.inter(fontSize: 14.sp),
                      ),
                      4.height,
                      Text(
                        'Pickup: ${_formatTimestamp(donation['pickupTime'])}',
                        style: GoogleFonts.inter(fontSize: 12.sp),
                      ),
                      4.height,
                      Text(
                        donation['isAvailable'] ? 'Available' : 'Not Available',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: donation['isAvailable']
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      10.height,
                      Center(
                          child: CustomButton(
                        text: 'Schedule Pickup',
                        onPressed: () => _schedulePickup(donation['donationId'],
                            donation.data() as Map<String, dynamic>),
                      ))
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
