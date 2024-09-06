import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/core/donor/screens/add_donation.dart';
import 'package:task7_food_savior_app/core/donor/services/home_screen_service.dart';
import 'package:task7_food_savior_app/core/donor/widgets/donation.dart';
import 'package:task7_food_savior_app/core/donor/widgets/drawer.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/widgets/app_bar.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';
import 'package:task7_food_savior_app/core/donor/services/donation_provider.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenViewModel(
        user: user,
        donationProvider: Provider.of<DonationProvider>(context, listen: false),
      ),
      child: Builder(
        builder: (context) => _HomeScreenContent(),
      ),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeScreenViewModel>(context);
    final donationProvider = Provider.of<DonationProvider>(context);

    return Scaffold(
      backgroundColor: foregroundColor,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, viewModel),
      body: RefreshIndicator(
        onRefresh: viewModel.refreshDonations,
        child: buildDonationList(donationProvider, viewModel),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: CustomButton(
          text: 'Add Donations',
          onPressed: () => _addDonation(context, viewModel.user),
        ),
      ),
    );
  }

  void _addDonation(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDonationScreen(user: user),
      ),
    );
  }
}
