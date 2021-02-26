import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class NotiMenu extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> order;
  NotiMenu(this.shopId, this.order);

  @override
  _NotiMenuState createState() => _NotiMenuState();
}

class _NotiMenuState extends State<NotiMenu> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userid ;
  String username ;
  String photo;
  Map<String, dynamic> dataShop = Map();
  final review = TextEditingController();
  num score = 2;
  int total = 0;
  void getShop() async {
    await firestore
        .collection("member")
        .where("userId", isEqualTo: widget.shopId)
        .get()
        .then((value) {
      setState(() {
        value.docs
            .map((QueryDocumentSnapshot e) => dataShop.addAll(e.data()))
            .toList();
        print(dataShop);
      });
    });
  }

  getuser()async{
    var data =await firestore
        .collection("member").doc(firebaseAuth.currentUser.uid).get();
        setState(() {
          userid = data["userId"];
          username = data["username"];
          photo = data["photo"];
        });

  }

  void addcoment(String review,num score)async{
      await firestore.collection("coments").doc().set({
        "coment":review,
        "score":score,
        "shopId":widget.shopId,
        "userId":userid,
        "username":username,
        "photo":photo
      });
      await firestore.collection("orders").doc(widget.order["orderpath"]).update({
        "staComent":true,
      });
      Navigator.pop(context);
      Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    widget.order["detail"].map((pice) {
      total = total + pice["price"] * pice["count"];
      setState(() {});
    }).toList();
    getuser();
    getShop();
  }

  Future<void> showReview() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รีวิวร้านค้า'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RatingBar.builder(
                  initialRating: 2,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      score = rating;
                    });
                  },
                  
                ),
                TextField(
              controller: review,
              decoration: InputDecoration(
                labelText: 'แสดงความคิดเห็น',
              ),
            )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                addcoment(review.text,score);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ข้อมูลออเดอร์"),
        ),
        body: SingleChildScrollView(
                  child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: dataShop.length < 1
                    ? CircularProgressIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${dataShop['username']}",
                                style: TextStyle(fontSize: 24),
                              ),
                              Text("${widget.order["cash"]}"),
                            ],
                          ),
                          Text("เบอร์โทรร้าน ${dataShop['phone']}"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("หมายเลขออเดอร์ ${widget.order["orderId"]}"),
                            ],
                          ),
                        ],
                      ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                color: Color.fromRGBO(196, 196, 196, 1),
                child: Center(
                    child: Text(
                        "เวลารับ : ${widget.order["time"] == null ? 'ไม่ระบุ' : widget.order["time"]}  สถานะ : " +
                            "${widget.order["status"]["staOrder"] ? widget.order["status"]["history"] ? widget.order["status"]["staComent"] ? 'เรียบร้อย' : 'อาหารครบแล้วรอรีวิว' : 'กำลังทำอาหาร' : 'รอการยืนยัน'}")),
              ),
              Text(
                "รายการอาหาร",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.order["detail"].length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 135,
                                child: Text(
                                    "${index + 1}. ${widget.order["detail"][index]["name"]}")),
                            Text("x${widget.order["detail"][index]["count"]}"),
                            Text(
                                "${widget.order["detail"][index]["price"] * widget.order["detail"][index]["count"]} บาท")
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
              widget.order["status"]["staOrder"]
                  ? widget.order["status"]["history"]
                      ? widget.order["status"]["staComent"]
                          ? Container()
                          : SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 50,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    "กดเพื่อรีวิว",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    showReview();
                                  }),
                            )
                      : Container()
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
