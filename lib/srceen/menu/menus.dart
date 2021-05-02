import 'package:bsrufood/main.dart';
import 'package:bsrufood/srceen/menu/review.dart';
import 'package:bsrufood/srceen/sqllite/data_item_order.dart';
import 'package:bsrufood/srceen/sqllite/item_clas.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Menus extends StatefulWidget {
  final String userId;
  final Map order;
  Menus(this.userId, this.order);
  @override
  _MenusState createState() => _MenusState();
}

class _MenusState extends State<Menus> {
  final database = DataItemOder();
  String shopid;
  List<dynamic> cartcount = [];
  List cart = [];

  void confirm(Map<String, dynamic> data) async {
    Alert(
      context: context,
      title: "คุณเลือกร้านอื่น หากดำเนินการต่อรายการในตะกร้าของคุณจะถูกลบ",
      buttons: [
        DialogButton(
          child: Text(
            "ใช่",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            database.delete();
            insertToclas(data);
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

  void insertToclas(Map<String, dynamic> data) async {
    final carts = await database.queryAllRows();
    var item = ItemClas.fromMap(data);
    if (carts.indexWhere((x) => x.shopId != shopid) != -1) {
      confirm(data);
      print("Deleted!!");
    }

    item.shopId = shopid;
    await database.insert(item);
    getcart();
  }

  void getcart() async {
    cart = await database.queryAllRows();
    cartcount = cartcount.map((e) {
      var index = cart.indexWhere((element) => element.food_id == e["food_id"]);
      e['shop_id'] = shopid;
      if (index != -1) {
        e['shop_id'] = cart[index].shopId;
        e["count"] = cart[index].count;
      }
      return e;
    }).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    shopid = widget.order["userId"];
    cartcount = widget.order["menus"] as List<dynamic>;
    // print(widget.order["menus"]);
    getcart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order["username"]),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Review(widget.order["userId"]));
                Navigator.push(context, route);
              },
            ),
          )
        ],
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return !cartcount[index]["status"]
                ? ListTile(
                    leading: cartcount[index]["image"] == null
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0))),
                            width: 100,
                            height: 100,
                            child: Center(
                                child: Text("สินค้าหมด",style: TextStyle(color: Colors.white),
                            )),
                          )
                        : Container(
                            width: 100,
                            height: 200,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                image: DecorationImage(
                                    image:
                                        NetworkImage(cartcount[index]["image"]),
                                      fit: BoxFit.cover,
                              colorFilter: ColorFilter.srgbToLinearGamma()),
                            ),
                            child: Center(
                              child: Text("สินค้าหมด",style: TextStyle(
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
                                ]
                              ),),
                            ),
                            ),
                    title: Text(
                      cartcount[index]["name"],
                      style: TextStyle(fontSize: 18.0
                      ),
                    ),
                    trailing: Text(
                      "${cartcount[index]["price"]} บาท",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    onTap: (){},
                    )
                : ListTile(
                    leading: cartcount[index]["image"] == null
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            width: 100,
                            height: 100,
                            child: Center(
                                child: Icon(
                              Icons.food_bank,
                              color: Colors.white,
                            )),
                          )
                        : Container(
                            width: 100,
                            height: 200,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                image: DecorationImage(
                                    image:
                                        NetworkImage(cartcount[index]["image"]),
                                    fit: BoxFit.cover))),
                    title: Text(
                      cartcount[index]["name"],
                      style: TextStyle(fontSize: 18.0),
                    ),
                    subtitle: cartcount[index]["count"] == null
                        ? Container()
                        : Text("x${cartcount[index]["count"]}"),
                    tileColor: cartcount[index]["count"] == null
                        ? Colors.white
                        : Color.fromRGBO(255, 51, 247, 0.1),
                    trailing: Text(
                      "${cartcount[index]["price"]} บาท",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    onTap: () {
                      insertToclas(cartcount[index]);
                    },
                  );
          },
          separatorBuilder: (context, index) => Divider(
                  color: Color.fromRGBO(255, 51, 247, 1),
                ),
          itemCount: cartcount.length),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
            child: Text(
              "ดูตระกร้า ${cart.length} รายการ",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
            onPressed: cart.length == 0
                ? null
                : () {
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (BuildContext context) => Mainhome(
                              pageSelect: 1,hidenBottomBar: true,
                            ));
                    Navigator.push(context, route);
                  }),
      ),
    );
  }
}
