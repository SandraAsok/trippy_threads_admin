// ignore_for_file: use_build_context_synchronously, await_only_futures

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trippy_threads_admin/Employee/assign.dart';
import 'package:trippy_threads_admin/orders/orders.dart';
import 'package:trippy_threads_admin/products/add_products.dart';
import 'package:trippy_threads_admin/Employee/requests.dart';
import 'package:trippy_threads_admin/products/productslist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController category = TextEditingController();
  String image = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Spacer(),
                  FloatingActionButton.extended(
                    label: const Text("Add Products"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProductsForm(),
                          ));
                    },
                  ),
                  const Spacer(),
                  const Text("OR"),
                  const Spacer(),
                  FloatingActionButton.extended(
                    label: const Text("Add Product Category"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Add New category"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile == null) {
                                    return;
                                  } else {
                                    File file = File(pickedFile.path);
                                    image = await uploadimage(file);
                                    setState(() {});
                                  }
                                },
                                child: image.isNotEmpty
                                    ? Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(image))),
                                      )
                                    : Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 2)),
                                        child: const Center(
                                            child: Text("Add cover pic")),
                                      ),
                              ),
                              TextField(
                                controller: category,
                                decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  try {
                                    if (category.text != "" &&
                                        image.isNotEmpty) {
                                      await FirebaseFirestore.instance
                                          .collection('categories')
                                          .add({
                                        'category': category.text,
                                        'cover': image,
                                      });
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("New Category added")),
                                    );
                                  }
                                  category.clear();
                                  image = "";
                                  Navigator.pop(context);
                                },
                                child: const Text("Add"))
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                label: const Text("View Products"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllProducts(),
                      ));
                },
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                label: const Text("Order's Status"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Orders(),
                      ));
                },
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                label: const Text("Employee Requests"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllRequests(),
                      ));
                },
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                label: const Text("Assign Duty"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Assign(),
                      ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> uploadimage(File file) async {
    firebase_storage.FirebaseStorage storage =
        await firebase_storage.FirebaseStorage.instance;
    DateTime now = DateTime.now();
    String timestamp = now.millisecondsSinceEpoch.toString();
    firebase_storage.Reference reference =
        storage.ref().child('images/$timestamp');
    firebase_storage.UploadTask task = reference.putFile(file);
    await task;
    String downloadurl = await reference.getDownloadURL();
    setState(() {
      image = downloadurl;
    });
    return image;
  }
}
