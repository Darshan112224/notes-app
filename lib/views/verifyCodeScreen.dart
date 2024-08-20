import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo1/admin/homeScreen.dart';
import 'package:demo1/views/homeScreen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String adminEmail;

  const VerifyCodeScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    required this.adminEmail,
  }) : super(key: key);

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final verificationCodeController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Verify"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: verificationCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: '6-Digit Code'),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      final credential = PhoneAuthProvider.credential(
                        verificationId: widget.verificationId,
                        smsCode: verificationCodeController.text,
                      );

                      try {
                        final authResult =
                            await auth.signInWithCredential(credential);
                        // Verify if user authentication is successful
                        if (authResult.user != null) {
                          // Check user role after successful login
                          checkUserRole();
                        } else {
                          // Handle authentication failure
                          setState(() {
                            isLoading = false;
                          });
                          // Show error message to the user
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Authentication failed. Please try again.'),
                          ));
                        }
                      } catch (e) {
                        // Handle authentication failure
                        setState(() {
                          isLoading = false;
                        });
                        // Show error message to the user
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                        ));
                      }
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
                          'Verify',
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

  void checkUserRole() async {
    if (widget.phoneNumber == '+919327244273') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminHomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }
}
