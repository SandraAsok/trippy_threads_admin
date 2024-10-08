// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:trippy_threads_admin/orders/assigned.dart';
import 'package:trippy_threads_admin/orders/delivered.dart';
import 'package:trippy_threads_admin/orders/pending.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Orders Pending"),
          centerTitle: true,
          bottom: TabBar(tabs: [
            Tab(child: Text("pending")),
            Tab(child: Text("assigned")),
            Tab(child: Text("delivered")),
          ]),
        ),
        body: TabBarView(
          children: [
            pending(),
            Assigned(),
            Delivered(),
          ],
        ),
      ),
    );
  }
}
