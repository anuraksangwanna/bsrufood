import 'package:bsrufood/srceen/home.dart';
import 'package:bsrufood/srceen/listfood.dart';
import 'package:bsrufood/srceen/login.dart';
import 'package:bsrufood/srceen/multify.dart';
import 'package:bsrufood/srceen/porfile.dart';
import 'package:bsrufood/srceen/regisfb.dart';
import 'package:bsrufood/srceen/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Myapp());
}


class Myapp extends StatelessWidget {
  const Myapp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      theme: ThemeData(primaryColor: Color.fromRGBO(255, 51, 247, 1)),
      initialRoute: '/',
      routes: {
        '/' : (_) => Splashscreen(),
        '/home' : (_) => Mainhome(),
        '/login' : (_) => Login(),
        '/register' : (_) => Registerfb()
      },
    );
  }
}

class Mainhome extends StatefulWidget {
  Mainhome({Key key}) : super(key: key);

  @override
  _MainhomeState createState() => _MainhomeState();
}

class _MainhomeState extends State<Mainhome> {
  @override
void onindex(int index){
     setState(() {
       page = index;
       print(page);
     });
  }
  int page = 0;
  var pages = [Home(),Listfood(),Multi(),Profile()];
   FirebaseAuth _firebase = FirebaseAuth.instance;
   
  @override
  void initState() {
    super.initState();
    print(_firebase.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("BSRU FOOD",style: TextStyle(fontSize: 32.0,),),
          centerTitle: true,
        ), body: pages[page],
        bottomNavigationBar: BottomNavigationBar(
        onTap:  onindex,
         currentIndex: page,
         type: BottomNavigationBarType.fixed,
         selectedItemColor: Colors.white,
         iconSize: 35.0,
          backgroundColor: Color.fromRGBO(255,51,247,1),
          items:[
             BottomNavigationBarItem(icon: Icon(Icons.home),title: Text("หน้าหลัก"))
            ,BottomNavigationBarItem(icon: Icon(Icons.list),title: Text("รายการสั่งซื้อ"))
            ,BottomNavigationBarItem(icon: Icon(Icons.notifications),title: Text("การแจ้งเตือน"))
            ,BottomNavigationBarItem(icon: Icon(Icons.person),title: Text("บัญชี"))
          ] ,
          ),
    );
  }
    }