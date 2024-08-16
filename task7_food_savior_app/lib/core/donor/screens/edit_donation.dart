import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/extensions/scaffold.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_textfield.dart';
import 'package:task7_food_savior_app/core/donor/services/edit_donation_service.dart';

class EditDonationScreen extends StatelessWidget {
  final User user;
  final String donationId;

  const EditDonationScreen(
      {Key? key, required this.user, required this.donationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditDonationViewModel(user: user, donationId: donationId),
      child: _EditDonationContent(),
    );
  }
}

class _EditDonationContent extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditDonationViewModel>(context);

    Future<void> _updateDonation() async {
      if (_formKey.currentState!.validate()) {
        bool success = await viewModel.updateDonation();
        if (success) {
          context.showSnackBar('Donation updated successfully');
          Navigator.pop(context);
        } else {
          context.showSnackBar('Failed to update donation. Please try again.');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Donation',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: iconTheme),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        labelText: 'Food Items',
                        initialValue: viewModel.foodItems,
                        onChanged: (value) => viewModel.foodItems = value,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter food items' : null,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        labelText: 'Quantity (for how many people)',
                        initialValue: viewModel.quantity.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            viewModel.quantity = int.tryParse(value) ?? 0,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter quantity' : null,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Text('Status:',
                              style: GoogleFonts.inter(fontSize: 16.sp)),
                          Switch(
                            value: viewModel.isAvailable,
                            onChanged: (value) {
                              viewModel.isAvailable = value;
                            },
                            activeColor: primaryColor,
                          ),
                          Text(
                              viewModel.isAvailable
                                  ? 'Available'
                                  : 'Not Available',
                              style: GoogleFonts.inter(fontSize: 16.sp)),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text('Pickup Time:',
                          style: GoogleFonts.inter(fontSize: 16.sp)),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () => viewModel.selectTime(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${viewModel.pickupTime.hour}:${viewModel.pickupTime.minute.toString().padLeft(2, '0')}',
                                style: GoogleFonts.inter(fontSize: 16.sp),
                              ),
                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        text: 'Update Donation',
                        onPressed: _updateDonation,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
