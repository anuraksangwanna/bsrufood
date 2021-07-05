
import 'package:bsrufood/srceen/menu/noti_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Multi extends StatefulWidget {
  final String userId ;
  Multi(this.userId);

  @override
  _MultiState createState() => _MultiState();
}

class _MultiState extends State<Multi> {
  
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot orderDetail;
  List<Map> noti = [];
  void getnoti() async {
    await firestore
        .collection("orders")
        .where("userId", isEqualTo: widget.userId)
        .get()
        .then((value) {
          print(value);
      value.docs.forEach((element) {
        getorders(element.data(),element.id);
      });
    });
  }

  void getorders(final data,String orderpath) async {
    Map<String, dynamic> order = Map();
    orderDetail = await data["detail"].get();
    order["cash"] = data["cash"];
    order["orderId"] = data["orderId"];
    order["orderDate"] = data["orderDate"];
    order["status"] = {
      "staOrder":data["staOrder"],
      "history":data["history"],
      "staComent":data["staComent"],
      };
    order["userId"] = data["shopId"];
    order["time"] = data["time"];
    order["orderList"] = data["orderList"];
    order["orderpath"] = orderpath;
    order["detail"] = orderDetail["detail"];
    setState(() {
      noti.add(order);
      noti.sort((m1,m2)=>m2["orderList"].compareTo(m1["orderList"]));
    });
  }

  @override
  void initState() {
    super.initState();
    getnoti();
  }

  Future _onRefresh()async{
    setState(() {
      noti=[];
    });
    getnoti();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
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
              trailing: noti[index]["status"]["staOrder"]
                  ?  Text(
                      "${noti[index]["status"]["history"] ? noti[index]["status"]["staComent"] ? 'เรียบร้อย' : 'อาหารครบแล้วรอรีวิว' : 'กำลังทำอาหาร'}",
                      style: TextStyle(color: Colors.green),
                    )
                  : Text("รอการยืนยัน", style: TextStyle(color: Colors.red)),
              tileColor: noti[index]["status"]["staOrder"] ? Colors.white : Color.fromRGBO(255, 0, 0, 0.3),            
              subtitle: Text("วันที่ ${noti[index]["orderDate"]}"),
              onTap: (){
                MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>NotiMenu(noti[index]["userId"],noti[index]));
                Navigator.push(context, route).then((value){
                  noti = [];
                  getnoti();});
              },
            );
          },
          
          itemCount: noti.length,
        ),
    );
  }
}