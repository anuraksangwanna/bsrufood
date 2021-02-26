

import 'dart:math';

import 'package:bsrufood/srceen/sqllite/data_item_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';
import 'package:qr/qr.dart';
import 'package:http/http.dart' as http;


class CartController{
    FirebaseFirestore firestore = FirebaseFirestore.instance;
  final BuildContext _context;
  DocumentSnapshot documents;
  bool stabtn = false;
  var uuid = Uuid();
  var now = DateTime.now();
  final database = DataItemOder();
  CartController(BuildContext context) : _context = context;

    void confirm(Map<String,dynamic> shop,String time,List cart,String userid)  {
    Alert(
      context: _context,
      title: "ทางร้านไม่รับเงินสด โปรดเอาคิวอาร์โค้ดนี้ไปแสดงกับร้านค้าเพื่อสแกนยืนยันออเดอร์",
      buttons: [
        DialogButton(
          child: Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(_context);
            addQrcode(shop,time,cart,userid);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "ยกเลิก",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(_context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void addQrcode(Map<String,dynamic> shop,String time,List cart,String userid)async{
    final documents = await firestore.collection("qrcode").get();
    int orders = documents.docChanges.length+1;
    String orderId = orders.toString();
    List detail = [];
    String id = uuid.v4().substring(0,20);
     cart.forEach((element) {
        Map<String,dynamic> detailMap = Map();
        detailMap["name"] = element.name;
        detailMap["price"] = element.price;
        detailMap["count"] = element.count;
        detailMap["name"] = element.name;
        detailMap["status"] = element.status;
        detailMap["option"] = [];
        detail.add(detailMap);
      });
      await firestore.collection("qrcode").doc(id).set(
        {"detail":FieldValue.arrayUnion(detail),
        "userId":userid,
        "orderId":orderId,
        "orderDate":"${now.day}/${now.month}/${now.year}",
        "shopId":shop["userId"],
        "status":false
        });
        showQrcode(id);
        database.delete();
        database.queryAllRows();
  }  

  void confirmOrder(Map<String,dynamic> shop,String time,List cart,String userid)  {
    Alert(
      context: _context,
      title: "กดตกลงเพื่อยืนออเดอร์",
      buttons: [
        DialogButton(
          child: Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if(stabtn){
                stabtn = false;
                print("รอดำเนินการ");
            }else{
                stabtn = true;
                addmenu(shop,time,cart,userid);
            }
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "ยกเลิก",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(_context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }  

Future addmenu(Map<String,dynamic> shop,String time,List cart,String userid)async{
    final documents = await firestore.collection("orders").get();
    int orders = documents.docChanges.length+1;
    String orderId = orders.toString();
    Random random = Random();
    int i = random.nextInt(1000);
      List detail = [];
      DocumentReference ref = firestore.collection('orderDetail').doc("O$orderId");
          cart.forEach((element) {
        Map<String,dynamic> detailMap = Map();
        detailMap["name"] = element.name;
        detailMap["price"] = element.price;
        detailMap["count"] = element.count;
        detailMap["name"] = element.name;
        detailMap["status"] = element.status;
        detailMap["option"] = [];
        detail.add(detailMap);
      });
      Map<String,dynamic> order = Map();
      order["cash"] = "จ่ายเงินสด";
      order["detail"] = ref;
      order["history"] = false;
      order["orderDate"] = "${now.day}/${now.month}/${now.year}";
      order["orderList"] = "$orderId";
      order["orderId"] = "$i";
      order["shopId"] = "${shop["userId"]}";
      order["staComent"] = false;
      order["staOrder"] = false;
      order["image"] = null;
      order["time"] = time == "" ? null : "$time";
      order["userId"] = "$userid";
      // print(order);
      try{
      await firestore.collection("orders").doc("O$orderId").set(order);
      await firestore.collection("orderDetail").doc("O$orderId").set({"detail":FieldValue.arrayUnion(detail)});
          shop["tokenUser"].forEach((value) {
         http.get("https://apibsrufood.000webhostapp.com/apiNotification.php?isAdd=true&token=$value&title=มีออเดอร์มาใหม่&body=Order-$i");
      });
      print(order);
      database.delete();
      database.queryAllRows();
      Navigator.pop(_context);
      }catch(eror){
          print("eror");
      }
         
  }

  void orderError(String limit) async {
    Alert(
      context: _context,
      title: "เกินกว่าที่ร้านค้ากำหนดไว้สูงสุดแค่ $limit รายการ",
      buttons: [
        DialogButton(
          child: Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(_context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  } 

    Future<void> showQrcode(String id) async {
  return showDialog<void>(
    context: _context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('นำบาร์โค้ดไปสแกน'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              PrettyQr(
                typeNumber: 3,
                size: 200,
                data: id,
                errorCorrectLevel: QrErrorCorrectLevel.M,
                roundEdges: true)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('ตกลง'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

    Future getCash(Map<String,dynamic> shop,String time,List cart,String userid)async{
      int total = 0;
          if(shop["cash"]){
              cart.forEach((element) {
                    total = total+element.count;
              });
              if(total > shop["orderCount"]){
                  orderError(shop["orderCount"].toString());
              }else{
                   confirmOrder(shop,time,cart,userid);
              }
          }else{
              confirm(shop,time,cart,userid);
          }     

}
}