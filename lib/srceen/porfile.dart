import 'package:bsrufood/srceen/login.dart';
import 'package:bsrufood/srceen/profile/edit_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
FirebaseAuth firebase = FirebaseAuth.instance;
 FirebaseFirestore firestore = FirebaseFirestore.instance;
final facebookLogin = FacebookLogin();
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
Map user;
Future<void> logout() async {
   List<String> tokenUser;
    await _firebaseMessaging.getToken().then((String token) {
      tokenUser = [token];
    });
    Map<String, dynamic> map = Map();
    map['tokenUser'] = FieldValue.arrayRemove(tokenUser);
    await firestore.collection("member").doc(firebase.currentUser.uid).update(map);
    await facebookLogin.logOut();
    await firebase.signOut();
    MaterialPageRoute route =
        MaterialPageRoute(builder: (BuildContext context) => Login());
    Navigator.pushAndRemoveUntil(
        context, route, (Route<dynamic> route) => false);
  }

  void getUser()async{
      await firestore.collection("member").doc(firebase.currentUser.uid).get().then((value) {
          setState(() {
            user = value.data();
          });
      });
    }

    @override
    void initState() { 
      super.initState();
      getUser();
    }

  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Image.network(firebase.currentUser.photoURL)),
          title: Text(firebase.currentUser.displayName),
          subtitle: Text("แก้ไขข้อมูลส่วนตัว",style: TextStyle(color:Colors.green),),
          onTap: () {
            MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>EditUser(user));
            Navigator.push(context, route).then((value){getUser();});
          },
        ),
        // Divider(),
        // ListTile(
        //   leading: Icon(Icons.settings),
        //   title: Text("การตั้งค่าแอปพลิเคชัน"),
        //   onTap: () {},
        // ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text("ออกจากระบบ"),
          onTap: ()=>logout(),
        ),
      ],
    );
  }
}
