import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/core/auth/services/auth_manager.dart';
import 'package:task7_food_savior_app/core/donor/services/donation_provider.dart';
import 'package:task7_food_savior_app/core/receiver/services/donation_provider.dart';

class Providers {
  static MultiProvider buildProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(
            create: (_) =>
                DonationProvider(FirebaseAuth.instance.currentUser!)),
        ChangeNotifierProvider(create: (_) => RDonationProvider()),
      ],
      child: child,
    );
  }
}
