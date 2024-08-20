// ignore_for_file: unnecessary_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo1/views/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  var note;
  TextEditingController noteController = TextEditingController();
  User? userId = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Note Screen"),
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Container(
                child: TextFormField(
                  controller: noteController,
                  maxLength: null,
                  decoration: InputDecoration(hintText: "Add Note"),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  note = noteController.text.trim();
                  if (note != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection("notes")
                          .doc()
                          .set({
                        "createAt": DateTime.now(),
                        "note": note,
                        "userId": userId?.uid,
                      }).then((value) => {
                                Get.offAll(() => HomeScreen()),
                                print("Data Added")
                              });
                    } catch (e) {
                      print("Error $e");
                    }
                  }
                },
                child: Text("Add Note"),
              ),
            ],
          )),
    );
  }
}
