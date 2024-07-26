import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_6_e_commerce_app/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBRLV7hgFr2Sph3f82eXK4dcJeZe9yExIU',
          appId: '1:218002329417:android:e4c68b48a8057167881498',
          messagingSenderId: '218002329417',
          projectId: 'e-commerce-6cddf',
          storageBucket: 'e-commerce-6cddf.appspot.com'));

  FirebaseAuth auth = FirebaseAuth.instance;
  runApp(MyApp(
    auth: auth,
  ));
}

class MyApp extends StatelessWidget {
  final FirebaseAuth auth;

  const MyApp({Key? key, required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
