
import 'package:bsrufood/srceen/hh.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("asd"),
      onPressed: () {
        MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context) => HH());
        Navigator.push(context, route);
      },
    );
  }
}
