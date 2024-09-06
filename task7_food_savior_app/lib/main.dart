import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task7_food_savior_app/splashScreen.dart';
import 'package:task7_food_savior_app/utils/services/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyD9CAsLrZNJ-AOj4vvaY2qMR2xH8UfRZ2M',
          appId: "1:321793752730:android:d7cb94fcbeb42e43eea923",
          messagingSenderId: "321793752730",
          projectId: "food-savior-7f2a4"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Providers.buildProviders(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          title: 'Food Savior',
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
