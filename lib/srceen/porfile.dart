import 'package:bsrufood/srceen/login.dart';
import 'package:bsrufood/srceen/profile/edit_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
bool statusButton = false;
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

    void alertConfirm() {
    Alert(context: context, title: "ออกจากระบบ?", buttons: [
      DialogButton(
        onPressed: statusButton == true
            ? () {}
            : () {
                setState(() {
                  statusButton = true;
                });
                logout();
              },
        child: statusButton
            ? CircularProgressIndicator()
            : Text(
                "ตกลง",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
        color: Color.fromRGBO(255, 0, 0, 1),
      ),
      DialogButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "ยกเลิก",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        color: Color.fromRGBO(0, 0, 0, 1),
      ),
    ]).show();
  }

    @override
    void initState() { 
      super.initState();
      getUser();
    }

  Widget build(BuildContext context) {
    print(firebase.currentUser.photoURL);
    return Column(
      children: [
        ListTile(
          leading: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image.network(firebase.currentUser.photoURL,width: 50,height: 50,fit: BoxFit.cover,)
            
          ),
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
          onTap: ()=>alertConfirm(),
        ),
      ],
    );
  }
}
