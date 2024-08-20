import 'package:demo1/views/homeScreen.dart';
import 'package:demo1/views/signinscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    // ignore: avoid_print
    print(user?.uid.toString());
  }

  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}

class DefaultFirebaseOptions {
  static var currentPlatform;
}
