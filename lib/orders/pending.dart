import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class pending extends StatefulWidget {
  const pending({super.key});

  @override
  State<pending> createState() => _pendingState();
}

class _pendingState extends State<pending> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('track', isEqualTo: "pending")
              .orderBy('placed_date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LinearProgressIndicator());
            }
            if (snapshot.hasError) {
              log(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No pending orders found.'));
            }

            final docs = snapshot.data!.docs;

            return Column(
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
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final snap = docs[index];
                    return ListTile(
                      leading: SvgPicture.asset(
                        snap['category'] == "poncho"
                            ? 'assets/poncho.svg'
                            : snap['category'] == "dapo"
                                ? 'assets/dapo.svg'
                                : snap['category'] == "hoodie"
                                    ? "assets/hoodie.svg"
                                    : snap['category'] == "wallart"
                                        ? "assets/wallart.svg"
                                        : snap['category'] == "shirt"
                                            ? "assets/shirt.svg"
                                            : snap['category'] == "shall"
                                                ? "assets/shall.svg"
                                                : snap['category'] == "cap"
                                                    ? "assets/cap.svg"
                                                    : "assets/pendant.svg",
                        width: 50.0,
                        height: 50.0,
                      ),
                      title: Text(snap['product_name']),
                      subtitle: Text('Order Id : ${snap.id}'),
                      trailing: Text(snap['placed_date']),
                    );
                  },
                ),
              ],
            );
          }),
    );
  }
}
