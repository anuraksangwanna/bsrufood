import 'package:bsrufood/srceen/cart/cart_qrcode.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HH extends StatefulWidget {
  final String userId;
  HH(this.userId);

  @override
  _HHState createState() => _HHState();
}

class _HHState extends State<HH> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot orderDetail;
  List<Map> noti = [];
  void getnoti() async {
    await firestore
        .collection("qrcode")
        .where("userId", isEqualTo: widget.userId)
        .where("status", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        getorders(element.data(),element.id);
      });
    });
  }

  void getorders(final data,String id) async {
    Map<String, dynamic> qrcode = Map();
    qrcode["orderId"] = data["orderId"];
    qrcode["orderDate"] = data["orderDate"];
    qrcode["qrcodeid"] = id ;
    qrcode["detail"] = data["detail"];
    noti.add(qrcode);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getnoti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title: Text("Qr Code"),),
          body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.all(
                  Radius.circular(30.0)
                )),
                width: 50,height: 50
                ,child: Center(child: Icon(Icons.qr_code,color: Colors.white,)),
                ),
              // leading: Container(
              //   width: 60.0,
              //   height: 60.0,
              //   // width: MediaQuery.of(context).size.width * 0.2,
              //   // height: MediaQuery.of(context).size.width * 0.2,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(60.0),
              //         image: DecorationImage(
              //           image: NetworkImage(noti[index]["profile"]),
              //           fit: BoxFit.cover,
              //         )),
              //   ),
              title: Text("Order-${noti[index]["orderId"]}"),            
              subtitle: Text("วันที่ ${noti[index]["orderDate"]}"),
              onTap: (){
                MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>CartQrCode(noti[index]));
                Navigator.push(context, route);
              }
            );
          },
          
          itemCount: noti.length,
        ),
    );
  }
}