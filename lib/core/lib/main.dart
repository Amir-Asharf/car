import 'package:car/core/services/user_service.dart';
import 'package:car/featuers/admin/admin_page.dart';
import 'package:car/featuers/admin/auth/auth_page.dart';
import 'package:car/featuers/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBTA7jHuEarBkKtoA7uMGyrNQRx9ZKa0no",
        appId: "1:917423254692:android:bcc20b635ee12284004a31",
        messagingSenderId: "917423254692",
        projectId: "melodic-bearing-455315-b0",
        storageBucket: "melodic-bearing-455315-b0.firebasestorage.app",
      ),
    );
    print("Firebase initialized successfully!");

    // Initialize UserService
    await UserService.init();
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Marketplace',
      theme: ThemeData(
        primaryColor: Colors.yellow,
        scaffoldBackgroundColor: const Color.fromARGB(255, 39, 38, 38),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 26, 25, 25),
          elevation: 0,
          titleTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.yellow));
          }

          if (snapshot.hasData && snapshot.data != null) {
            return HomePageView();
          }

          return AuthPage();
        },
      ),
    );
  }
}
