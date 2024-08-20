// ignore_for_file: unused_label

//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo1/views/homeScreen.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  TextEditingController noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Note"),
        backgroundColor: Colors.red,
      ),
      body: Container(
          child: Column(
        children: [
          TextFormField(
              controller: noteController
                ..text = "${Get.arguments['note'].toString()}"),
          SizedBox(
            width: 10.0,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("notes")
                    .doc(Get.arguments['docId'].toString())
                    .update({
                  "note": noteController.text.trim(),
                }).then((value) => {
                          Get.offAll(() => HomeScreen()),
                          print("Data Updated")
                        });
              },
              child: Text("Update"))
        ],
      )),
    );
  }
}
