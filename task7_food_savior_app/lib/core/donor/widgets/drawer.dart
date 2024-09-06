import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/core/auth/screens/login.dart';
import 'package:task7_food_savior_app/core/donor/screens/expired_donation.dart';
import 'package:task7_food_savior_app/core/donor/screens/pickup_screen.dart';
import 'package:task7_food_savior_app/core/donor/services/home_screen_service.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';

Widget buildDrawer(BuildContext context, HomeScreenViewModel viewModel) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildDrawerHeader(viewModel),
        if (viewModel.userRole != null)
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(viewModel.userRole!),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Pickup'),
          onTap: () => _pickup(context, viewModel.user),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Expired Donations'),
          onTap: () => _navigateToExpiredDonations(context),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () => _logout(context, viewModel),
        ),
      ],
    ),
  );
}

Widget _buildDrawerHeader(HomeScreenViewModel viewModel) {
  return DrawerHeader(
    decoration: const BoxDecoration(color: primaryColor),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: foregroundColor,
          radius: 30.r,
          child: Text(
            viewModel.userName != null ? viewModel.userName![0] : '',
            style: GoogleFonts.inter(fontSize: 30.sp, color: textColor),
          ),
        ),
        10.height,
        Text(
          viewModel.userName ?? '',
          style: GoogleFonts.inter(fontSize: 20.sp, color: foregroundColor),
        ),
        Text(
          viewModel.userEmail ?? '',
          style: GoogleFonts.inter(
            color: foregroundColor,
            fontSize: 16.sp,
          ),
        ),
      ],
    ),
  );
}

void _pickup(BuildContext context, User user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DonorPickupScreen(user: user),
    ),
  );
}

void _navigateToExpiredDonations(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ExpiredDonationsScreen(),
    ),
  );
}

Future<void> _logout(
    BuildContext context, HomeScreenViewModel viewModel) async {
  await viewModel.logout();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}
