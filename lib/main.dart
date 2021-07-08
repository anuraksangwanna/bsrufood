import 'package:badges/badges.dart';
import 'package:bsrufood/srceen/home.dart';
import 'package:bsrufood/srceen/listfood.dart';
import 'package:bsrufood/srceen/login.dart';
import 'package:bsrufood/srceen/multify.dart';
import 'package:bsrufood/srceen/porfile.dart';
import 'package:bsrufood/srceen/regisfb.dart';
import 'package:bsrufood/srceen/hh.dart';
import 'package:bsrufood/srceen/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main(List<String> args) async {
  Intl.defaultLocale ="th";
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Myapp());
}


class Myapp extends StatelessWidget {
  const Myapp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      theme: ThemeData(primaryColor: Color.fromRGBO(255, 51, 247, 1),buttonTheme: ButtonThemeData(buttonColor: Color.fromRGBO(255, 51, 247, 1))),
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
  final int pageSelect;
  final bool hidenBottomBar;
  Mainhome({this.pageSelect,this.hidenBottomBar = false});

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
  String userId;
   FirebaseAuth _firebase = FirebaseAuth.instance;
   FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
   
sendNotification(String title,String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.max, priority: Priority.high,
        );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
 
    var platformChannelSpecifics = NotificationDetails(android:androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics );
 
    await flutterLocalNotificationsPlugin.show(111, title,
        body, platformChannelSpecifics,
        payload: 'I just haven\'t Met You Yet');
  }

  void getUser()async{
      await firestore.collection("member").doc(_firebase.currentUser.uid).get().then((value) {
          setState(() {
              userId = value["userId"];
          });
      });
    }

    Widget pages(int i){
  print(i);
  return i == 0 ? Home(userId) : i == 1 ? Listfood(userId) : i == 2 ? Multi(userId) : Profile();
}

  @override
  void initState() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {
      print("onDidReceiveLocalNotification called.");
    }); 
    final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS);
flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: (payload) {
      // when user tap on notification.
      print("onSelectNotification called.");
    });

    super.initState();
    if(widget.pageSelect !=null){
      page = widget.pageSelect;
      setState(() {});
    }
    message();
    getUser();
  }

  void message(){
    firebaseMessaging.configure(
        onMessage: (msg) async{
            print("onMessage: $msg");
            Map mapNotification = msg["notification"];
            String title = mapNotification["title"];
            String body = mapNotification["body"];
            return sendNotification(title,body);
        },
      onLaunch: (msg) async {
        print("onLaunch: $msg");
        return;
      },
      onResume: (msg) async {
        print("onResume: $msg");
        return;
      },
    );
  }
  List title =  ["BSRU FOOD","ตะกร้าสินค้า","การแจ้งเตือน","บัญชี"];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('orders').where("userId",isEqualTo: userId).where("staOrder",isEqualTo: false).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        int noti = snapshot.connectionState == ConnectionState.waiting ? 0 : snapshot.data.docs.length;
    return  Scaffold(
        appBar: AppBar(
          title: Text(title[page],style: TextStyle(fontSize: 32.0,),),
          actions: page == 1 ? [
            IconButton(
              icon: Icon(Icons.qr_code),
              onPressed: (){
                 MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>HH(userId));
                 Navigator.push(context, route);
              },
            )
          ] :[],
          centerTitle: true,
        ), body: pages(page),
        bottomNavigationBar: widget.hidenBottomBar ? null :  BottomNavigationBar(
        onTap:  onindex,
         currentIndex: page,
         type: BottomNavigationBarType.fixed,
         selectedItemColor: Colors.white,
         iconSize: 35.0,
          backgroundColor: Color.fromRGBO(255,51,247,1),
          items:[
             BottomNavigationBarItem(icon: Icon(Icons.home),title: Text("หน้าหลัก"))
            ,BottomNavigationBarItem(icon: Icon(Icons.shopping_cart),title: Text("รายการสั่งซื้อ"))
            , BottomNavigationBarItem(
            icon: Badge(
            badgeContent: Text(noti.toString(),style: TextStyle(color: Colors.white)) ,
            toAnimate: true,
            position: BadgePosition(top: -3,start: 30),
            child: Icon(
                  Icons.notifications,
                  size:35.0
                ),   
            ),title:Text("การแจ้งเตือน"))
            ,BottomNavigationBarItem(icon: Icon(Icons.person),title: Text("บัญชี"))
          ] ,
          ),
    );
  });
  }
    }