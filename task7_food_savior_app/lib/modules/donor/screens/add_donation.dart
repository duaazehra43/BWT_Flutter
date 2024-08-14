import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task7_food_savior_app/core/constants/colors.dart';
import 'package:task7_food_savior_app/core/extensions/scaffold.dart';
import 'package:task7_food_savior_app/core/shared/custombuttons.dart';
import 'package:task7_food_savior_app/core/shared/customtextfield.dart';
import 'package:task7_food_savior_app/modules/donor/services/add_donation_service.dart';

class AddDonationScreen extends StatefulWidget {
  final User user;

  const AddDonationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddDonationScreenState createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddDonationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddDonationViewModel(user: widget.user);
  }

  Future<void> _addDonation() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _viewModel.addDonation();
      if (success) {
        context.showSnackBar('Donation added successfully');
        Navigator.pop(context);
      } else {
        context.showSnackBar('Failed to add donation. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Add Donation', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: ColorConstants.backgroundColor,
        iconTheme: IconThemeData(color: ColorConstants.iconTheme),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  labelText: 'Food Items',
                  onChanged: (value) => _viewModel.foodItems = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter food items' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Quantity (for how many people)',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      _viewModel.quantity = int.tryParse(value) ?? 0,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter quantity' : null,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text('Status:', style: GoogleFonts.inter(fontSize: 16.sp)),
                    Switch(
                      value: _viewModel.isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _viewModel.isAvailable = value;
                        });
                      },
                      activeColor: ColorConstants.backgroundColor,
                    ),
                    Text(_viewModel.isAvailable ? 'Available' : 'Not Available',
                        style: GoogleFonts.inter(fontSize: 16.sp)),
                  ],
                ),
                SizedBox(height: 16.h),
                Text('Pickup Time:', style: GoogleFonts.inter(fontSize: 16.sp)),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _viewModel
                      .selectTime(context)
                      .then((_) => setState(() {})),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_viewModel.pickupTime.hour}:${_viewModel.pickupTime.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(fontSize: 16.sp),
                        ),
                        Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  text: 'Add Donation',
                  onPressed: _addDonation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
