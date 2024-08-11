// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AssignConfirm extends StatefulWidget {
  const AssignConfirm({super.key});

  @override
  State<AssignConfirm> createState() => _AssignConfirmState();
}

class _AssignConfirmState extends State<AssignConfirm> {
  int totalorders = 0;
  DateFormat outputFormat = DateFormat("dd/MM/yyyy");

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    Future fetchTotalOrders() async {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      var filteredOrders = querySnapshot.docs
          .where((doc) => doc['address'].contains(args['selectedcity']))
          .toList();

      int total = filteredOrders.length;
      setState(() {
        totalorders = total;
      });
    }

    fetchTotalOrders();

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Total orders regarding ${args['selectedcity']} : $totalorders",
                style: GoogleFonts.abhayaLibre(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var filteredorder = snapshot.data!.docs
                        .where((doc) =>
                            doc['address'].contains(args['selectedcity']))
                        .toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredorder.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(filteredorder[index]['product_name']),
                          subtitle: Text(
                              "Quantity : ${filteredorder[index]['quantity']}"),
                          trailing: Column(
                            children: [
                              Text("₹ ${filteredorder[index]['totalPrice']}/-"),
                              Text(
                                filteredorder[index]['payment'] == "razorpay"
                                    ? "Paid"
                                    : "cod",
                                style: GoogleFonts.abhayaLibre(
                                    fontSize: 20,
                                    color: filteredorder[index]['payment'] ==
                                            "razorpay"
                                        ? Colors.green
                                        : Colors.red),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
        bottomSheet: MaterialButton(
          onPressed: () async {
            try {
              // Get the filtered orders
              QuerySnapshot querySnapshot =
                  await FirebaseFirestore.instance.collection('orders').get();

              var filteredOrders = querySnapshot.docs
                  .where((doc) => doc['address'].contains(args['selectedcity']))
                  .toList();

              // Create a list of maps containing order details
              List<Map<String, dynamic>> orderDetails =
                  filteredOrders.map((doc) {
                return {
                  'product_name': doc['product_name'],
                  'quantity': doc['quantity'],
                  'totalPrice': doc['totalPrice'],
                  'payment': doc['payment'],
                  'address': doc['address'].split("+").join(","),
                };
              }).toList();

              // Add the collected data to 'assigned_orders' collection
              await FirebaseFirestore.instance
                  .collection('assigned_orders')
                  .add({
                'orders_no': totalorders,
                'ordered_city': args['selectedcity'],
                'order_details': orderDetails,
                'assigned_date': outputFormat.format(DateTime.now()),
                'employee_name': args['employee_name'],
                'employee_phone': args['employee_phone'],
                'employee_email': args['employee_email'],
              });

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Orders Assigned Successfully!'),
              ));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error assigning orders: $e'),
              ));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("ASSIGN ORDERS"),
          ),
        ),
      ),
    );
  }
}
