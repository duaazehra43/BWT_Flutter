import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/text.dart';
import 'package:task7_food_savior_app/utils/extensions/scaffold.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_textfield.dart';
import 'package:task7_food_savior_app/core/donor/services/add_donation_service.dart';

class AddDonationScreen extends StatefulWidget {
  final User user;

  const AddDonationScreen({super.key, required this.user});

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
      bool success = await _viewModel.addDonation(context);
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
        title: Text('Add Donation', style: appBarStyle),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: iconTheme),
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
                16.height,
                CustomTextField(
                  labelText: 'Quantity (for how many people)',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      _viewModel.quantity = int.tryParse(value) ?? 0,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter quantity' : null,
                ),
                16.height,
                Row(
                  children: [
                    Text('Status:', style: labelStyle),
                    Switch(
                      value: _viewModel.isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _viewModel.isAvailable = value;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                    Text(_viewModel.isAvailable ? 'Available' : 'Not Available',
                        style: labelStyle),
                  ],
                ),
                16.height,
                Text('Pickup Time:', style: labelStyle),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _viewModel
                      .selectTime(context)
                      .then((_) => setState(() {})),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_viewModel.pickupTime.hour}:${_viewModel.pickupTime.minute.toString().padLeft(2, '0')}',
                          style: labelStyle,
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                24.height,
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
