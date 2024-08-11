// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AllRequests extends StatefulWidget {
  const AllRequests({super.key});

  @override
  State<AllRequests> createState() => _AllRequestsState();
}

class _AllRequestsState extends State<AllRequests> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('employees_delivery')
                .where('status', isEqualTo: "pending")
                .snapshots(),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final snap = snapshot.data!.docs[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(snap['licence']),
                      Row(
                        children: [
                          Text("Vehicle",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text("           : ",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text("${snap['vehicle']}",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Employee Name",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(" : ",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(snap['name'],
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Employee Age",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(" : ",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(snap['age'],
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Employee Phone",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(" : ",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(snap['phone'],
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Spacer(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                                color: Colors.amber[50],
                                onPressed: snap['vehicle'] == "no"
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                content: MaterialButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'employees_delivery')
                                                    .doc(snap.id)
                                                    .update({'vehicle': 'yes'});
                                                final url = Uri(
                                                    scheme: 'sms',
                                                    queryParameters: {
                                                      'body':
                                                          "Welcome to TRIPPY THREADS !\nyour Employee Request has been Approved.\nYou can collect your vehicle from our outlet.\nLocation Link:\nhttps://www.google.com/maps?q=trippy+threads+pvt.ltd,+vytila,+Ernakulam\nFor any queries please contact us:\n8075190230\nor email to trippythreadsadmin@gmail.com"
                                                    },
                                                    path: snap['phone']);
                                                if (await canLaunchUrl(url)) {
                                                  launchUrl(url);
                                                }
                                              },
                                              child: Text("Approve vehicle"),
                                            ));
                                          },
                                        );
                                      }
                                    : () async {
                                        await FirebaseFirestore.instance
                                            .collection('employees_delivery')
                                            .doc(snap.id)
                                            .update({'status': 'approved'});
                                      },
                                child: Text(snap['vehicle'] == "no"
                                    ? "Approve Vehicle"
                                    : "Approve Employee")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                                color: Colors.amber[50],
                                onPressed: () {},
                                child: Text("Reject")),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}
