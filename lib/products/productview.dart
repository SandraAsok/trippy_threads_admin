// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_threads_admin/utilities.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List<dynamic> image = args['image'];
    TextEditingController updatedstock = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            minheight,
            minheight,
            CarouselSlider(
              options: CarouselOptions(
                height: 450.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(seconds: 1),
                viewportFraction: 0.8,
              ),
              items: image
                  .map((item) => Container(
                        width: 300,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(item), fit: BoxFit.cover)),
                      ))
                  .toList(),
            ),
            minheight,
            Text(
              args['product_name'],
              style: GoogleFonts.aclonica(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            minheight,
            Row(children: [
              const Spacer(),
              Text(
                "Price : ",
                style: GoogleFonts.aclonica(color: Colors.white),
              ),
              Text(
                "₹ ${args['price']}/-",
                style: GoogleFonts.aclonica(color: Colors.white),
              ),
              const Spacer(),
            ]),
            minheight,
            Text(
              "Product Desription : ",
              style: GoogleFonts.aclonica(
                  color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
            ),
            minheight,
            Text(
              args['description'],
              style: GoogleFonts.aclonica(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            minheight,
            minheight,
            Text(
              "Product Details : ",
              style: GoogleFonts.aclonica(
                  color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
            ),
            minheight,
            Text(
              args['details'].split("+").join("\n"),
              style: GoogleFonts.aclonica(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            minheight,
            minheight,
            Center(
              child: Text(
                args['stock'] <= 1
                    ? "Out of Stock : ${args['stock']}"
                    : "Stock : ${args['stock']}",
                style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: args['stock'] <= 1 ? Colors.red : Colors.white,
                    fontSize: 20),
              ),
            ),
            minheight,
            minheight,
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: TextField(
                            controller: updatedstock,
                            decoration: const InputDecoration(
                              labelText: "updated stock number",
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(args['id'])
                                      .update({
                                    'stock': int.parse(updatedstock.text)
                                  });
                                  setState(() {
                                    args['stock'] =
                                        int.parse(updatedstock.text);
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Update"))
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Update Stock")),
            )
          ],
        ),
      ),
    );
  }
}
