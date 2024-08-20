import 'package:demo1/admin/homeScreen.dart';
import 'package:demo1/views/loginWithPhone.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo1/views/forgotPasswordScreen.dart';
import 'package:demo1/views/homeScreen.dart';
import 'package:demo1/views/signupScreen.dart';

enum LoginMethod {
  emailPassword,
  phoneNumber,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController loginIdentifierController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  LoginMethod _loginMethod = LoginMethod.emailPassword;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Login Screen'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 300.0,
                child: Lottie.asset("assets/Animation - 1706161022566.json"),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                  controller: loginIdentifierController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Email or Phone Number',
                    enabledBorder: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                  controller: loginPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    hintText: 'Password',
                    enabledBorder: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              // Radio buttons for selecting login method
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: LoginMethod.emailPassword,
                    groupValue: _loginMethod,
                    onChanged: (value) {
                      setState(() {
                        _loginMethod = value as LoginMethod;
                      });
                    },
                  ),
                  Text('Email/Password'),
                  Radio(
                    value: LoginMethod.phoneNumber,
                    groupValue: _loginMethod,
                    onChanged: (value) {
                      setState(() {
                        _loginMethod = value as LoginMethod;
                      });
                    },
                  ),
                  Text('Phone Number'),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  String loginIdentifier =
                      loginIdentifierController.text.trim();
                  String loginPassword = loginPasswordController.text.trim();
                  if (_loginMethod == LoginMethod.emailPassword) {
                    // Perform email/password login
                    try {
                      final UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: loginIdentifier,
                        password: loginPassword,
                      );
                      final User? firebaseUser = userCredential.user;
                      if (firebaseUser != null) {
                        // Check if the logged-in user is an admin
                        if (loginIdentifier == 'admin18@gmail.com') {
                          // Navigate to admin home screen
                          Get.to(() => AdminHomeScreen());
                        } else {
                          // Navigate to regular home screen
                          Get.to(() => HomeScreen());
                        }
                      } else {
                        print("Check Email & Password");
                      }
                    } on FirebaseAuthException catch (e) {
                      print("Error $e");
                    }
                  } else {
                    // Perform phone number login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginWithPhoneScreen(),
                      ),
                    );
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 5.0),
              GestureDetector(
                onTap: () {
                  Get.to(() => ForgotPasswordScreen());
                },
                child: Container(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Forgot Password'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              GestureDetector(
                onTap: () {
                  Get.to(() => SignUpScreen());
                },
                child: Container(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Don`t Have Account'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
