import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Assigned extends StatefulWidget {
  const Assigned({super.key});

  @override
  State<Assigned> createState() => _AssignedState();
}

class _AssignedState extends State<Assigned> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('assigned_orders')
              .orderBy('assigned_date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LinearProgressIndicator());
            }

            if (snapshot.hasError) {
              log(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No assigned orders found.'));
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Total number of assigned orders : ${snapshot.data!.docs.length}",
                    style: GoogleFonts.abhayaLibre(
                        color: Colors.green[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final snap = docs[index];
                      return Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(snap['product_name']),
                          subtitle: Column(
                            children: [
                              Text('Order Id : ${snap.id}'),
                              Text('Assigned to : ${snap['employee_name']}'),
                              Row(
                                children: [
                                  const Spacer(),
                                  MaterialButton(
                                    color: Colors.amber[50],
                                    onPressed: () async {
                                      Uri uri = Uri(
                                          path: snap['employee_phone'],
                                          scheme: 'tel');
                                      if (await canLaunchUrl(uri)) {
                                        launchUrl(uri);
                                      }
                                    },
                                    child: const Text("Call"),
                                  ),
                                  const Spacer(),
                                  MaterialButton(
                                    color: Colors.amber[50],
                                    onPressed: () async {
                                      Uri uri = Uri(
                                          path: snap['employee_phone'],
                                          scheme: 'sms');
                                      if (await canLaunchUrl(uri)) {
                                        launchUrl(uri);
                                      }
                                    },
                                    child: const Text("SMS"),
                                  ),
                                  const Spacer(),
                                ],
                              )
                            ],
                          ),
                          trailing: Text(snap['assigned_date']),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
