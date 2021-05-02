import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';


class CartQrCode extends StatelessWidget {
  final Map data ;
    CartQrCode(this.data);
  @override
  Widget build(BuildContext context) {
    Map documents = data;
    int total = 0;
    documents["detail"].map((e) {
        total = total + e["price"] * e["count"];
    }).toList();
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ข้อมูลออเดอร์"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "รายการอาหาร",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents == null ? 0 : documents["detail"].length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 135,
                                child: Text(
                                    "${index + 1}. ${documents["detail"][index]["name"]}")),
                            Text("x${documents["detail"][index]["count"]}"),
                            Text(
                                "${documents["detail"][index]["price"] * documents["detail"][index]["count"]} บาท")
                          ],
                        ),
                      );
                    }),
              ),
              Container(
                padding: EdgeInsets.all(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "รวมเป็นเงิน",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "$total",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
                PrettyQr(
                typeNumber: 3,
                size: 200,
                data: documents["qrcodeid"],
                errorCorrectLevel: QrErrorCorrectLevel.M,
                roundEdges: true)
              ])
        )));}
}