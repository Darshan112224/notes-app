import 'package:demo1/views/signinScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo1/views/profileScreen.dart';
import 'package:demo1/views/createNoteScreen.dart';
import 'package:demo1/views/editNoteScreen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchThemePreference();
  }

  void fetchThemePreference() async {
    setState(() {
      _isDarkMode = false;
    });
  }

  void toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> generateReport() async {
    final pdf = pw.Document();
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: user?.uid)
        .get();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'User Notes Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 20),
              for (final doc in querySnapshot.docs)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (doc.data()?.containsKey('date') ??
                        false) // Null check added
                      pw.Text('Date: ${doc['date'] ?? 'N/A'}'),
                    pw.Text('Time: ${doc['time']}'),
                    pw.Text('Note: ${doc['note']}'),
                    pw.Divider(),
                  ],
                ),
            ],
          );
        },
      ),
    );

    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/notes_report.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());
    print('Report Generated Successfully: $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreen'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              toggleTheme(!_isDarkMode);
            },
          ),
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Get.to(() => const LoginScreen());
              },
            ),
        ],
      ),
      drawer: user != null
          ? Drawer(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData || snapshot.data != null) {
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    var userName = userData['userName'];
                    var imageUrl = userData['imageUrl'];
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(imageUrl ?? ''),
                              ),
                              SizedBox(height: 8),
                              Text(
                                userName ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.home),
                          title: Text('Home'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Log Out'),
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            Get.to(() => const LoginScreen());
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Profile'),
                          onTap: () {
                            Get.to(() => const ProfileScreen());
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.picture_as_pdf),
                          title: Text('Generate Report'),
                          onTap: generateReport,
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            )
          : SizedBox.shrink(),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('userId', isEqualTo: user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong!');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No Data Found'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var note = snapshot.data!.docs[index]['note'];
                var docId = snapshot.data!.docs[index].id;
                return Card(
                  child: ListTile(
                    title: Text(note),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => EditNoteScreen(),
                                arguments: {'note': note, 'docId': docId});
                          },
                          child: Icon(Icons.edit),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('notes')
                                .doc(docId)
                                .delete();
                          },
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            onTap: () {
              Get.to(() => CreateNoteScreen());
            },
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
