import 'package:bsrufood/set_datetimepicker.dart';
import 'package:bsrufood/srceen/cart/cart_controller.dart';
import 'package:bsrufood/srceen/cart/credit.dart';
import 'package:bsrufood/srceen/sqllite/data_item_order.dart';
import 'package:bsrufood/srceen/sqllite/item_clas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Listfood extends StatefulWidget {
  final String userid;
  Listfood(this.userid);

  @override
  _ListfoodState createState() => _ListfoodState();
}

class _ListfoodState extends State<Listfood> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CartController cartController;
  String time ;
  Map<String, dynamic> shop = Map();
  final database = DataItemOder();
  var cart = [];
  int total = 0;

  void getShop() async {
    await firestore
        .collection("member")
        .where("userId", isEqualTo: cart[0].shopId)
        .get()
        .then((value) {
      value.docs.map((e) {
        setState(() {
          shop = e.data();
        });
      }).toList();
    });
  }

  void confirm(int id) async {
    Alert(
      context: context,
      title: "คุณต้องการลบเมนูนี้",
      buttons: [
        DialogButton(
          child: Text(
            "ลบ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            database.deletelist(id);
            total = 0;
            getcart();
            Navigator.pop(context);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "ยกเลิก",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void deleteCart() {
    database.delete();
    setState(() {
      cart = [];
      total = 0;
    });
  }

  void uplist(ItemClas sd, String aa) async {
    if (aa == "del" && sd.count == 1) {
      confirm(sd.id);
    } else {
      await database.updatelist(sd, aa);
      total = 0;
      getcart();
    }
  }

  void getcart() async {
    cart = await database.queryAllRows();
    cart.map((e) {
      total = total + e.price * e.count;
    }).toList();
    print(cart);
    if (cart.length > 0) {
      getShop();
    }
    setState(() {});
  }

  void showtime(){
    DatePicker.showPicker(context, showTitleActions: true,
                      onChanged: (date) {
                    time = "${date.hour}:${date.minute}";
                  }, onConfirm: (date) {
                    time = "${date.hour}:${date.minute}";
                    setState(() {});
                  },
                      pickerModel: SetDateTimePicker(currentTime: DateTime.now()),
                      locale: LocaleType.en);
  }


  @override
  void initState() {
    super.initState();
    getcart();
    cartController = CartController(context);
  }

  @override
  Widget build(BuildContext context) {
    return cart.length == 0
        ? Center(
            child: Text("ยังไม่มีรายการ"),
          )
        : Container(
            padding: EdgeInsets.all(17),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "เมนู",
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        "จำนวน",
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        "ราคา",
                        style: TextStyle(fontSize: 24),
                      )
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 10)),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: 100,
                                  child: Text(
                                    cart[index].name,
                                    style: TextStyle(fontSize: 18),
                                  )),
                              Row(
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.remove),
                                      color: Colors.red,
                                      iconSize: 18,
                                      onPressed: () {
                                        uplist(cart[index], "del");
                                      }),
                                  Text(
                                    "x${cart[index].count}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.add),
                                      color: Colors.blue,
                                      iconSize: 18,
                                      onPressed: () {
                                        uplist(cart[index], "add");
                                      }),
                                ],
                              ),
                              Text(
                                "${cart[index].price * cart[index].count} บาท",
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          );
                        },
                        itemCount: cart.length),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 10)),
                  InkWell(
                    onTap: ()=>showtime(),
                    child: Row(
                      children: [
                        Icon(Icons.alarm),
                       time == null ? Text("ต้องการระบุเวลา : ไม่ระบุ") : Text("ต้องการระบุเวลา : $time")
                      ],
                    ),
                  ),
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
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.blue,
                        child: Text(
                          "ชำระผ่านธนาคาร",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          MaterialPageRoute route = MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Credit(widget.userid,time,shop, cart, total));
                          Navigator.push(context, route).then((value){
                            setState(() {
                              cart = [];
                              total = 0;
                              getcart();
                            });
                          });
                        }),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          "ชำระเงินสด",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () =>
                            cartController.getCash(shop,time, cart, widget.userid)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.red,
                        child: Text(
                          "ยกเลิกรายการ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => deleteCart()),
                  )
                ],
              ),
            ),
          );
  }
}
