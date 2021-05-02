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
  String urlProfile =
      "https://firebasestorage.googleapis.com/v0/b/bsrufood.appspot.com/o/Member%2Fbaseline_account_circle_black_48dp.png?alt=media&token=2269f14d-3913-4911-9baa-94b0e615c7a9";
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
    order["profile"] = shop["profile"];
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
    // print(shopdata);
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top:23),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>Menus(widget.userId,shopdata[index]));
                Navigator.push(context, route).then((value) {
                  shopdata = [];
                  getdata();
                });
              },
                          child: Center(
                child: Container(
                  decoration: shopdata[index]["profile"] == urlProfile
                      ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.pink,
                        )
                      : BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(shopdata[index]["profile"]),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.srgbToLinearGamma()),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 170,
                  child: Container(
                    margin: EdgeInsets.only(left:10,bottom:3),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(shopdata[index]["username"],
                              style: TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(-2, -1.5),
                                        color: Colors.black),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(2, -1.5),
                                        color: Colors.black),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.5, 1.5),
                                        color: Colors.black),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(-1.5, 1.5),
                                        color: Colors.black),
                                  ])),
                    ),
                  )),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: shopdata.length),
    );
  }
}
