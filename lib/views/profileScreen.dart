import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'editProfileScreen.dart';
import 'homeScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      setState(() {
        _isLoading = true;
      });
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          _userData = snapshot.data();
          if (_userData != null &&
              _userData!['imageUrl'] != null &&
              _userData!['imageUrl'].isNotEmpty) {
            // Construct a valid network URL for the image
            _userData!['imageUrl'];
            // 'https://firebasestorage.googleapis.com/v0/b/your-storage.appspot.com/o/' +
            //     _userData!['imageUrl'] +
            //     '?alt=media';
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editProfile() async {
    Get.offAll(() => const EditProfileScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.off(() => HomeScreen());
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40), // Increased spacing
            _isLoading
                ? CircularProgressIndicator() // Show loading indicator while fetching data
                : CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _userData != null && _userData!['imageUrl'] != null
                            ? NetworkImage(_userData!['imageUrl'])
                            : null,
                    // child: Icon(
                    //   Icons.person,
                    //   size: 80,
                    //   color: Colors.grey[600],
                    // ),
                  ),
            SizedBox(height: 40), // Increased spacing
            if (_userData != null) ...[
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_userData!['userName']),
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_userData!['userEmail']),
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    'Phone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_userData!['userPhone']),
                ),
              ),
            ],
            SizedBox(height: 20), // Increased spacing
            Center(
              // Centering the button
              child: ElevatedButton(
                onPressed: _editProfile,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 50.0,
                    vertical: 20.0,
                  ), // Increased button size
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20), // Increased spacing
            // // Toggle theme button
            // ElevatedButton(
            //   onPressed: () {
            //     Get.changeTheme(
            //         Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
            //   },
            //   child: Text(Get.isDarkMode
            //       ? 'Switch to Light Theme'
            //       : 'Switch to Dark Theme'),
            // ),
          ],
        ),
      ),
    );
  }
}
