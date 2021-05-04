import 'dart:io';
import 'dart:math';
import 'package:bsrufood/srceen/sqllite/data_item_order.dart';
import 'package:bsrufood/srceen/sqllite/item_clas.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class Credit extends StatefulWidget {
  String userid;
  String time;
  final Map shop;
  final List menu;
  final int total;
  Credit(this.userid, this.time, this.shop, this.menu, this.total);

  @override
  _CreditState createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Map<String, dynamic> shop = Map();
  String urlPhoto;
  final picker = ImagePicker();
  File _image;
  bool stabtn;
  final database = DataItemOder();
  var now = DateTime.now();

  void confirm() async {
    Alert(
      context: context,
      title: "กรุณาใส่สลิปโอนเงิน",
      buttons: [
        DialogButton(
          child: Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
          setState(() {stabtn = false;});
            Navigator.pop(context);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    ).show();
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void addmenu()async{
    final documents = await firestore.collection("orders").get();
    int orders = documents.docChanges.length+1;
    String orderId = orders.toString();
    Random random = Random();
    int i = random.nextInt(1000);
      List detail = [];
      DocumentReference ref = firestore.collection('orderDetail').doc("O$orderId");
      print("ผู้ใช้งาน ${widget.userid}");
      print("ร้านค้า ${widget.shop}");
      print("ออเดอร์ ${widget.menu}");
      widget.menu.forEach((element) {
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
      order["cash"] = "โอนเงิน";
      order["detail"] = ref;
      order["history"] = false;
      order["orderDate"] = "${now.day}/${now.month}/${now.year}";
      order["orderList"] = int.parse(orderId);
      order["orderId"] = "$i";
      order["shopId"] = "${widget.shop["userId"]}";
      order["staComent"] = false;
      order["staOrder"] = false;
      order["image"] = urlPhoto;
      order["time"] = widget.time == null ? null : "${widget.time}";
      order["userId"] = "${widget.userid}";
      print(order);
      await firestore.collection("orders").doc("O$orderId").set(order);
      await firestore.collection("orderDetail").doc("O$orderId").set({"detail":FieldValue.arrayUnion(detail)});
      widget.shop["tokenUser"].forEach((value) {
         http.get("https://apinotificationbsrufood.000webhostapp.com/apiNotification.php?isAdd=true&token=$value&title=มีออเดอร์มาใหม่&body=Order-$i");

      });
      database.delete();
      Navigator.pop(context);
  }

  @override
  void initState() { 
    super.initState();
    stabtn = false;
  }

  Future<void> uploadPictureToStore() async {
    setState(() {stabtn = true;});
    Random random = Random();
    int i = random.nextInt(100000);
    if (_image != null) {
      await firebaseStorage
          .ref()
          .child('cash/Cash$i.jpg')
          .putFile(_image);
      urlPhoto = await firebaseStorage
          .ref()
          .child('cash/Cash$i.jpg')
          .getDownloadURL();
      addmenu();
    } else {
      confirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("โอนเงิน"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(196, 196, 196, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ยอดเงินที่ต้องชำระทั้งหมด",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "${widget.total}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 15)),
              Image.network(
                widget.shop["barcode"],
                width: 150,
                fit: BoxFit.cover,
              ),
              Padding(padding: EdgeInsets.only(bottom: 15)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "ธนาคาร ${widget.shop["bank"]} \n เลขบัญชี ${widget.shop["prompt"]}"),
                  SizedBox(
                    width: 79,
                    height: 50,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Color.fromRGBO(196, 196, 196, 1.0),
                        child: Text(
                          "คัดลอก",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          FlutterClipboard.copy('${widget.shop["prompt"]}')
                              .then((value) => value);
                        }),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                      ),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      }),
                  Text("ใส่รูปสลิปการโอนเงิน")
                ],
              ),
              _image != null
                  ? Image.file(
                      _image,
                      width: 150,
                      height: 150,
                    )
                  : Image.asset("images/empty.jpg", width: 150),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 300,
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text("ยืนยัน",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            onPressed: stabtn ? null : ()=>uploadPictureToStore()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
