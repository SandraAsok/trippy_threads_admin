// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trippy_threads_admin/utilities.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddProductsForm extends StatefulWidget {
  const AddProductsForm({super.key});

  @override
  State<AddProductsForm> createState() => _AddProductsFormState();
}

class _AddProductsFormState extends State<AddProductsForm> {
  String? categoryvalue;
  String? colourcodevalue;
  List category = [];

  @override
  void initState() {
    fetchcategories();
    super.initState();
  }

  Future fetchcategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      List values = querySnapshot.docs.map((doc) => doc['category']).toList();
      setState(() {
        category = values;
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  List<String> colorcode = [
    "black",
    "white",
    "multicolor",
    "spiritual",
  ];

  List<String> image = [];

  TextEditingController productname = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController stock = TextEditingController();

  Future addproduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'image': image,
        'product_name': productname.text,
        'description': description.text,
        'details': details.text,
        'price': price.text,
        'category': categoryvalue,
        'colorcode': colourcodevalue,
        'stock': int.parse(stock.text),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product Added Successfully")));
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text("Something went wrong"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"))
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  final pickedfile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedfile == null) {
                    return;
                  } else {
                    File file = File(pickedfile.path);
                    image = await uploadimage(file);
                    setState(() {});
                  }
                },
                child: image.isEmpty
                    ? Container(
                        height: 350,
                        width: 250,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2)),
                        child: const Center(child: Text("Add product image")),
                      )
                    : Container(
                        height: 350,
                        width: 250,
                        decoration: BoxDecoration(
                            image:
                                DecorationImage(image: NetworkImage(image[0])),
                            border: Border.all(color: Colors.black, width: 2)),
                      ),
              ),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: productname,
                decoration: InputDecoration(
                    labelText: "Product Name",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ))),
              ),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: description,
                decoration: InputDecoration(
                    labelText: "Product Description",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 5,
                controller: details,
                decoration: InputDecoration(
                    labelText: "Product Details",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Product Price",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Select a category',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
                value: categoryvalue,
                items: category.map<DropdownMenuItem>((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) {
                  categoryvalue = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Select a colourcode',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
                value: colourcodevalue,
                items: colorcode.map<DropdownMenuItem>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  colourcodevalue = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: stock,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Stock",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ))),
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blueGrey)),
                onPressed: () {
                  if (productname.text.isNotEmpty &&
                      description.text.isNotEmpty &&
                      details.text.isNotEmpty &&
                      price.text.isNotEmpty &&
                      categoryvalue!.isNotEmpty &&
                      colourcodevalue!.isNotEmpty &&
                      stock.text.isNotEmpty) {
                    addproduct();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("something went wrong")));
                  }
                  Navigator.pop(context);
                  productname.clear();
                  details.clear();
                  price.clear();
                  categoryvalue = "";
                  colourcodevalue = "";
                  stock.clear();
                },
                child: Text(
                  "Add",
                  style: GoogleFonts.aclonica(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }

  Future<List<String>> uploadimage(File file) async {
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
      image.add(downloadurl);
    });
    return image;
  }
}
