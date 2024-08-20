import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'profileScreen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _imageUrl = ''; // Initialize image URL to empty string
    fetchUserData(); // Fetch user data when screen initializes
  }

  Future<void> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Retrieve user data from Firestore
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // Extract user details
        final userName = userData['userName'];
        final userEmail = userData['userEmail'];
        final userPhone = userData['userPhone'];
        final imageUrl = userData['imageUrl'];

        // Update the text controllers and image URL with retrieved data
        setState(() {
          _nameController.text = userName;
          _emailController.text = userEmail;
          _phoneController.text = userPhone;
          _imageUrl = imageUrl;
        });
      } else {
        print('No user signed in.');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> updateProfile(String newName, String newEmail, String newPhone,
      String newImageUrl) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, dynamic> updatedUserData = {
          'userName': newName,
          'userEmail': newEmail,
          'userPhone': newPhone,
          'imageUrl': newImageUrl,
          'updateDateTime': DateTime.now(),
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(updatedUserData);
        print('Profile updated successfully!');
      } else {
        print('No user signed in.');
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      try {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('Images')
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        final uploadTask = storageReference.putFile(File(pickedFile.path));
        await uploadTask.whenComplete(() async {
          final imageUrl = await storageReference.getDownloadURL();
          setState(() {
            _imageUrl = imageUrl;
          });
        });
      } catch (error) {
        print('Error uploading image: $error');
      }
    } else {
      // Handle the case where no image is picked
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.off(ProfileScreen());
          },
          icon: Icon(LineAwesomeIcons.angle_left),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage:
                      _imageUrl.isEmpty ? null : NetworkImage(_imageUrl),
                  child: _imageUrl.isEmpty ? Icon(Icons.camera_alt) : null,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: 'Enter your phone number',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String newName = _nameController.text.trim();
                  String newEmail = _emailController.text.trim();
                  String newPhone = _phoneController.text.trim();

                  // Check if any of the fields are empty
                  if (newName.isEmpty ||
                      newEmail.isEmpty ||
                      newPhone.isEmpty ||
                      _imageUrl.isEmpty) {
                    // Show error message if any field is empty
                    Get.snackbar(
                      'Error',
                      'All fields are required!',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // All fields are filled, proceed to update profile
                  await updateProfile(newName, newEmail, newPhone, _imageUrl);
                  Get.snackbar(
                    'Success',
                    'Profile updated successfully!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.purple,
                    colorText: Colors.black,
                  );
                  await Future.delayed(Duration(seconds: 3));
                  Get.off(ProfileScreen());
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
