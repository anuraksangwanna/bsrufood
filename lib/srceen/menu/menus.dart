import 'package:bsrufood/srceen/menu/list_menu.dart';
import 'package:bsrufood/srceen/menu/review.dart';
import 'package:bsrufood/srceen/sqllite/data_item_order.dart';
import 'package:bsrufood/srceen/sqllite/item_clas.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Menus extends StatefulWidget {
  final String userId;
  final Map order;
  Menus(this.userId,this.order);
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
      var index = cart.indexWhere((element) => element.name == e["name"]);
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
    print("Shopid = $shopid");
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
            return !cartcount[index]["status"] ? Container() : ListTile(
              leading: cartcount[index]["image"] == null
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      width: 40,
                      height: 40,
                      child: Center(
                          child: Icon(
                        Icons.food_bank,
                        color: Colors.white,
                      )),
                    )
                  : Image.network(cartcount[index]["image"]),
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
          separatorBuilder: (context, index) => !cartcount[index]["status"] ? Container() : Divider(
                color: Color.fromRGBO(255, 51, 247, 1),
              ),
          itemCount: cartcount.length),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
            child: Text(
              "ดูตะกร้า ${cart.length} รายการ",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
            onPressed: cart.length == 0 ? null : () {
              MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>ListMenu(widget.userId));
              Navigator.push(context, route);
            }),
      ),
    );
  }
}
