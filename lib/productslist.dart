// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  TextEditingController updatedstock = TextEditingController();
  List category = [];
  String? categoryvalue;

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
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
                      setState(() {
                        categoryvalue = value;
                      });
                    },
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 3,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('category', isEqualTo: categoryvalue)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final product = snapshot.data!.docs[index];
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'view',
                                        arguments: {
                                          'id': product.id,
                                          'image': product['image'],
                                          'product_name':
                                              product['product_name'],
                                          'description': product['description'],
                                          'details': product['details'],
                                          'price': product['price'],
                                          'category': product['category'],
                                          'colorcode': product['colorcode'],
                                          'stock': product['stock'],
                                        });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        height: 150,
                                        width: 500,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: Row(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          product['image']
                                                              [0]))),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 20),
                                            child: SizedBox(
                                              width: 200,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    product['product_name'],
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                  Text(
                                                    product['stock'] <= 1
                                                        ? "Out of Stock : ${product['stock']}"
                                                        : "Stock : ${product['stock']}",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color:
                                                            product['stock'] <=
                                                                    1
                                                                ? Colors.red
                                                                : Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                  product['stock'] <= 1
                                                      ? ElevatedButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  content:
                                                                      TextField(
                                                                    controller:
                                                                        updatedstock,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          "updated stock number",
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection(
                                                                                  'products')
                                                                              .doc(product
                                                                                  .id)
                                                                              .update({
                                                                            'stock':
                                                                                int.parse(updatedstock.text)
                                                                          });
                                                                        },
                                                                        child: Text(
                                                                            "Update"))
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Text(
                                                              "Update Stock"))
                                                      : Text(" "),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                      IconButton.filled(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Alert !"),
                                                  content: Text(
                                                      "Are you sure you want to delete ?"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("No")),
                                                    TextButton(
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'products')
                                                              .doc(product.id)
                                                              .delete();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Product Deleted")));
                                                        },
                                                        child: Text("Yes")),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(Icons.delete))
                                    ],
                                  ),
                                ));
                          },
                        );
                      } else if (snapshot.hasError) {}
                      return CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
