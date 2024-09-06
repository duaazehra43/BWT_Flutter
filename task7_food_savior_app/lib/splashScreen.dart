import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task7_food_savior_app/core/auth/screens/login.dart';
import 'package:task7_food_savior_app/core/donor/screens/home_screen.dart';
import 'package:task7_food_savior_app/core/receiver/screens/home_screen.dart';
import 'package:task7_food_savior_app/utils/constants/icons.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    if (user == null) {
      _navigateToLogin();
    } else {
      final userRole = await _getUserRole(user!.uid);
      if (userRole == 'Donor') {
        _navigateToHomeScreen();
      } else if (userRole == 'Receiver') {
        _navigateToRHomeScreen();
      } else {
        _navigateToLogin();
      }
    }
  }

  Future<String?> _getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      return userDoc.get('role') as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  void _navigateToLogin() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  void _navigateToHomeScreen() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    user: user!,
                  )));
    });
  }

  void _navigateToRHomeScreen() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RHomeScreen(
                    user: user!,
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          logoIcon,
          height: 250.h,
          width: 250.w,
        ),
      ),
    );
  }
}
