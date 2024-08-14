import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/core/constants/colors.dart';
import 'package:task7_food_savior_app/core/constants/text.dart';
import 'package:task7_food_savior_app/core/shared/custombuttons.dart';
import 'package:task7_food_savior_app/modules/donor/services/donation_provider.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userEmail;
  String? userRole;
  List<QueryDocumentSnapshot> donations = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('userId', isEqualTo: widget.user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        donations = querySnapshot.docs;
      });
    } catch (e) {
      print("Error fetching donations: $e");
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String date = DateFormat('dd MMM yyyy').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return '$date, $time';
  }

  void _editDonation(String donationId) {
    context.push('/editDonations/$donationId', extra: widget.user);
  }

  void _deleteDonation(String donationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .delete();
      _fetchDonations(); // Refresh the list
    } catch (e) {
      print("Error deleting donation: $e");
    }
  }

  Future<void> _loadUserData() async {
    await check();
    setState(() {});
  }

  Future<void> check() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      userName = userDoc['name'];
      userEmail = userDoc['email'];
      userRole = userDoc['role'];
    } catch (e) {
      print("Error: $e");
      // Handle error appropriately
    }
  }

  void _addDonation() {
    context.push('/addDonations', extra: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: AppBar(
          title: Text(
            'Food Savior',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: ColorConstants.backgroundColor,
          iconTheme: IconThemeData(
            color: ColorConstants.iconTheme,
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
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18.0.w,
                        vertical: 0,
                      ),
                      prefixIcon: Icon(
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
              decoration: BoxDecoration(
                color: ColorConstants.backgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: ColorConstants.foregroundColor,
                    radius: 30,
                    child: Text(
                      userName != null ? userName![0] : '',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(userName ?? '',
                      style: drawerTextStyle.copyWith(fontSize: 20.sp)),
                  Text(
                    userEmail ?? '',
                    style: TextStyle(
                      color: ColorConstants.foregroundColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (userRole != null)
              ListTile(
                leading: Icon(Icons.person),
                title: Text(userRole!),
              ),
            Divider(),
          ],
        ),
      ),
      body: Consumer<DonationProvider>(
        builder: (context, donationProvider, child) {
          if (donationProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (donationProvider.error != null) {
            return Center(child: Text('Error: ${donationProvider.error}'));
          }

          if (donationProvider.donations.isEmpty) {
            return Center(child: Text('No donations available.'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: donationProvider.donations.length,
            itemBuilder: (context, index) {
              var donation = donationProvider.donations[index];
              return Card(
                color: ColorConstants.dropColor,
                shadowColor: ColorConstants.shadowColor,
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
                            style: GoogleFonts.inter(
                                fontSize: 16.sp, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Quantity: ${donation['quantity']}',
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Pickup: ${_formatTimestamp(donation['pickupTime'])}',
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            donation['isAvailable']
                                ? 'Available'
                                : 'Not Available',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: donation['isAvailable']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PopupMenuButton<String>(
                        color: ColorConstants.dropColor,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editDonation(donation.id);
                          } else if (value == 'delete') {
                            donationProvider.deleteDonation(donation.id);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
          child: CustomButton(text: 'Add Donations', onPressed: _addDonation)),
    );
  }
}
