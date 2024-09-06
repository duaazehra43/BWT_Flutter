import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/core/receiver/services/home_screen_provider.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';

Widget buildDrawer(BuildContext context, RHomeScreenProvider provider) {
  return Drawer(
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
                  provider.userName?.isNotEmpty == true
                      ? provider.userName![0]
                      : '',
                  style: GoogleFonts.inter(fontSize: 30.sp, color: textColor),
                ),
              ),
              10.height,
              Text(
                provider.userName ?? '',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  color: foregroundColor,
                ),
              ),
              Text(
                provider.userEmail ?? '',
                style: GoogleFonts.inter(
                  color: foregroundColor,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
        if (provider.userRole != null)
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(provider.userRole!),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Scheduled Pickup'),
          onTap: () => provider.navigateToScheduledPickup(context),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () => provider.logout(context),
        ),
      ],
    ),
  );
}
