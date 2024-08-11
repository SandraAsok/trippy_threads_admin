// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Assign extends StatefulWidget {
  const Assign({super.key});

  @override
  State<Assign> createState() => _AssignState();
}

class _AssignState extends State<Assign> {
  List cities = [];
  String? selectedcity;

  @override
  void initState() {
    super.initState();
    fetchCities();
    fetchTotalOrders();
  }

  Future fetchCities() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('employees_delivery').get();

    Map<String, bool> cityMap = {};

    for (var doc in querySnapshot.docs) {
      List<String> employeeCities = List<String>.from(doc['cities']);
      for (var city in employeeCities) {
        cityMap[city] = true;
      }
    }

    setState(() {
      cities = cityMap.keys.toList();
    });
  }

  int totalorders = 0;

  Future fetchTotalOrders() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    int total = 0;
    total = querySnapshot.docs.length;
    setState(() {
      totalorders = total;
    });
  }

  int totalcityorders = 0;

  Future fetchcityOrders() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    var filteredOrders = querySnapshot.docs
        .where((doc) => doc['address'].contains(selectedcity))
        .toList();

    int total = filteredOrders.length;
    //  total = querySnapshot.docs.length;
    setState(() {
      totalcityorders = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Total Orders to be assign : $totalorders",
                    style: GoogleFonts.abhayaLibre(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DropdownButtonFormField(
                    hint: Text("select employer city"),
                    onChanged: (value) {
                      setState(() {
                        selectedcity = value.toString();
                      });
                      fetchcityOrders();
                    },
                    value: selectedcity,
                    items: cities.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Total orders regarding $selectedcity : $totalcityorders",
                    style: GoogleFonts.abhayaLibre(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('employees_delivery')
                        .where('cities', arrayContains: selectedcity)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        log(snapshot.error.toString());
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: LinearProgressIndicator());
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final snap = snapshot.data!.docs[index];
                          final city =
                              snap['cities'].toString().replaceAll('[', ' ');
                          final cities = city.replaceAll(']', ' ');
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(snap['name']),
                                    Text(snap['phone']),
                                    Text(cities),
                                  ],
                                ),
                                Spacer(),
                                MaterialButton(
                                    color: Colors.amber[50],
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, 'assignconfirm',
                                          arguments: {
                                            'selectedcity': selectedcity,
                                            'employee_name': snap['name'],
                                            'employee_phone': snap['phone'],
                                            'employee_email': snap['email'],
                                          });
                                    },
                                    child: Text(
                                      "Assign   Orders",
                                      style:
                                          GoogleFonts.abhayaLibre(fontSize: 15),
                                    )),
                              ],
                            ),
                          );
                        },
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
