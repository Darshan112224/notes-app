import 'package:demo1/admin/homeScreen.dart';
import 'package:demo1/views/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:demo1/views/verifyCodeScreen.dart';

class LoginWithPhoneScreen extends StatefulWidget {
  const LoginWithPhoneScreen({Key? key});

  @override
  State<LoginWithPhoneScreen> createState() => _LoginWithPhoneScreenState();
}

class _LoginWithPhoneScreenState extends State<LoginWithPhoneScreen> {
  final phoneNumberController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;

  String verificationId = '';

  Future<void> sendOTP() async {
    String phoneNumber = phoneNumberController.text.trim();

    setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        navigateBasedOnRole(phoneNumber);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isLoading = false;
        });
        print("Error: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          isLoading = false;
          this.verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          isLoading = false;
        });
        print("Code auto retrieval timed out");
      },
      timeout: Duration(seconds: 60),
    );
  }

  void navigateBasedOnRole(String phoneNumber) {
    // Check if the phone number belongs to an admin
    if (phoneNumber == '9328828078') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminHomeScreen(),
        ),
      );
    } else {
      // If not an admin, proceed as a regular user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("LoginWithPhone"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(hintText: '+1 123 456 7890'),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      sendOTP().then((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyCodeScreen(
                              verificationId: verificationId,
                              phoneNumber: phoneNumberController.text.trim(),
                              adminEmail: 'admin18@gmail.com',
                            ),
                          ),
                        );
                      });
                    },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
