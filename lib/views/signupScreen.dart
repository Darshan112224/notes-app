import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo1/views/signinScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController userNameController;
  late TextEditingController userPhoneController;
  late TextEditingController userEmailController;
  late TextEditingController userPasswordController;

  String? imageUrl;
  bool _isPasswordVisible =
      false; // Track the visibility state of the password field

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    userPhoneController = TextEditingController();
    userEmailController = TextEditingController();
    userPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    userNameController.dispose();
    userPhoneController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    super.dispose();
  }

  // Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _uploadImageAndSaveUrl() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 80, // Maximum height of the picked image
      maxWidth: 100, // Adjust image quality as needed (0-100)
    );

    if (pickedFile != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('Images');
      Reference referenceImageUpload = referenceDirImages.child(uniqueFileName);
      try {
        await referenceImageUpload.putFile(File(pickedFile.path));
        final downloadUrl = await referenceImageUpload.getDownloadURL();
        print('Download URL: $downloadUrl'); // Print the download URL
        setState(() {
          imageUrl = downloadUrl;
        });

        // Call signup method after fetching the image
        if (imageUrl != null) {
          final userName = userNameController.text.trim();
          final userPhone = userPhoneController.text.trim();
          final userEmail = userEmailController.text.trim();
          final userPassword = userPasswordController.text.trim();
          await _signUpUser(
              userName, userPhone, userEmail, userPassword, imageUrl!);
        }
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> _signUpUser(String userName, String userPhone, String userEmail,
      String userPassword, String imageUrl) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );
      final user = userCredential.user;
      if (user != null) {
        final userData = {
          'userName': userName,
          'userPhone': userPhone,
          'userEmail': userEmail,
          'imageUrl': imageUrl,
          'signupDateTime': DateTime.now(),
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
        Get.off(() => const LoginScreen());
      }
    } catch (error) {
      print('Error signing up user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('SignUp Screen'),
        actions: [
          Icon(Icons.more_vert),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 250.0,
              child: Lottie.asset("assets/Animation - 1706161022566.json"),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: 'User Name',
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userPhoneController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Phone',
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userEmailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userPasswordController,
                obscureText:
                    !_isPasswordVisible, // Toggle obscureText based on visibility state
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: IconButton(
                    onPressed:
                        _togglePasswordVisibility, // Toggle visibility when pressed
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
            IconButton(
              onPressed: _uploadImageAndSaveUrl,
              icon: const Icon(Icons.camera_alt),
            ),
            if (imageUrl != null) Image.network(imageUrl!),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final userName = userNameController.text.trim();
                final userPhone = userPhoneController.text.trim();
                final userEmail = userEmailController.text.trim();
                final userPassword = userPasswordController.text.trim();

                // Check if imageUrl is not null before signing up
                if (imageUrl != null) {
                  await _signUpUser(userName, userPhone, userEmail,
                          userPassword, imageUrl!)
                      .then((value) => {
                            // ignore: avoid_prin
                          });
                } else {
                  print('Image URL is null'); // Log error if imageUrl is null
                }
              },
              child: Text('SignUP'),
            ),
          ],
        ),
      ),
    );
  }
}
