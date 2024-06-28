import 'package:flutter/material.dart';
import 'package:task_5_google_classroom_clone/views/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyArEJ__pdM_fUMxwm6DG0yWcSTJYTIytzI',
          appId: '1:546254047424:android:f6d12b30b456c6469d4525',
          messagingSenderId: '546254047424',
          projectId: 'classroom-65d32',
          storageBucket: 'classroom-65d32.appspot.com'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
