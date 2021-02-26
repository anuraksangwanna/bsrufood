import 'package:bsrufood/srceen/hh.dart';
import 'package:bsrufood/srceen/menu/menus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  final String userId;
  Home(this.userId);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List shopdata = [];
 
  void getdata() async {
    await firestore
        .collection("member")
        .where("userStatus", isEqualTo: "admin")
        .where("statusShop", isEqualTo: true)
        .get()
        .then((value) {
      print(value.docChanges.length);
      value.docs.forEach((element) {
        getOrder(element.data());
        print(element.data().length);
      });
    });
  }

  void getOrder(var shop) async {
     Map<String, dynamic> order = Map();
    DocumentSnapshot menu = await shop["menus"].get();
    order["menus"] = menu["menudetail"];
    order["bank"] = shop["bank"];
    order["barcode"] = shop["barcode"];
    order["cash"] = shop["cash"];
    order["orderCount"] = shop["orderCount"];
    order["phone"] = shop["phone"];
    order["prompt"] = shop["prompt"];
    order["tokenUser"] = shop["tokenUser"];
    order["userId"] = shop["userId"];
    order["username"] = shop["username"];
    setState(() {
      shopdata.add(order);
    });
    print(shopdata);
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.all(
                Radius.circular(30.0)
              )),
              width: 50,height: 50
              ,child: Center(child: Icon(Icons.store,color: Colors.white,)),
              ),
            title: Text(shopdata[index]["username"],style: TextStyle(fontSize: 24),),
            onTap: (){
              MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>Menus(widget.userId,shopdata[index]));
              Navigator.push(context, route).then((value) {
                shopdata = [];
                getdata();
              });
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: shopdata.length);
  }
}
