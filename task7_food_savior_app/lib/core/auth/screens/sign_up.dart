import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/icons.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_textfield.dart';
import 'package:task7_food_savior_app/core/auth/services/signup_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final RegistrationViewModel _viewModel = RegistrationViewModel();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.register(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              10.height,
              Image.asset(logoIcon),
              10.height,
              CustomTextField(
                labelText: 'Name',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                onChanged: (value) => _viewModel.name = value,
              ),
              CustomTextField(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an email' : null,
                onChanged: (value) => _viewModel.email = value,
              ),
              CustomTextField(
                labelText: 'Phone',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone number' : null,
                onChanged: (value) => _viewModel.phone = value,
              ),
              CustomTextField(
                labelText: 'Address',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your address' : null,
                onChanged: (value) => _viewModel.address = value,
              ),
              CustomTextField(
                labelText: 'Password',
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                onChanged: (value) => _viewModel.password = value,
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                dropdownColor: dropColor,
                value: _viewModel.role,
                decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    )),
                items: ['Donor', 'Receiver'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _viewModel.role = newValue!;
                  });
                },
              ),
              20.height,
              CustomButton(
                text: 'Register',
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
