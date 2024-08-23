import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:task7_food_savior_app/core/donor/screens/add_donation.dart';
import 'package:task7_food_savior_app/core/donor/screens/edit_donation.dart';
import 'package:task7_food_savior_app/core/donor/screens/home_screen.dart';
import 'package:task7_food_savior_app/core/auth/screens/login.dart';
import 'package:task7_food_savior_app/core/auth/screens/sign_up.dart';
import 'package:task7_food_savior_app/core/donor/screens/pickup_screen.dart';
import 'package:task7_food_savior_app/core/receiver/screens/home_screen.dart';
import 'package:task7_food_savior_app/core/receiver/screens/schedule_pickup.dart';
import 'package:task7_food_savior_app/splashScreen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegistrationScreen(),
    ),
    GoRoute(
      path: '/homescreen',
      builder: (context, state) {
        final user = state.extra as User;
        return HomeScreen(user: user);
      },
    ),
    GoRoute(
      path: '/Rhomescreen',
      builder: (context, state) {
        final user = state.extra as User;
        return RHomeScreen(user: user);
      },
    ),
    GoRoute(
      path: '/schedule',
      builder: (context, state) {
        final user = state.extra as User;
        return ScheduledPickupScreen(user: user);
      },
    ),
    GoRoute(
      path: '/pickup',
      builder: (context, state) {
        final user = state.extra as User;
        return DonorPickupScreen(user: user);
      },
    ),
    GoRoute(
      path: '/addDonations',
      builder: (context, state) {
        final user = state.extra as User;
        return AddDonationScreen(user: user);
      },
    ),
    GoRoute(
      path: '/editDonations/:donationId',
      builder: (context, state) {
        final user = state.extra as User;
        final donationId = state.pathParameters['donationId']!;
        return EditDonationScreen(user: user, donationId: donationId);
      },
    ),
  ],
);
