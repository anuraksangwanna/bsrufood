import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Registerfb extends StatefulWidget {
  @override
  _RegisterfbState createState() => _RegisterfbState();
}

class _RegisterfbState extends State<Registerfb> {
  final keyfrom = GlobalKey<FormState>();
  final name = TextEditingController();
  final userController = TextEditingController();
  final stucode = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumber = TextEditingController();
  final reCeipt = TextEditingController();
  String bank ;
  var now = DateTime.now();
  String getDatetime;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot snapshot ;
  String memberid;

  final picker = ImagePicker();
  bool statusBool;

  File _image;
  File _imgReceipt;
  String urlPhoto, urlPhoto1;

  @override
  void initState() { 
    super.initState();
    statusBool = false;
    // print(memberid);
  }

  void _onSave() {
      if (keyfrom.currentState.validate()) {
        keyfrom.currentState.save();
        setupDisplayName();
      }
  }

  Future<void> setupDisplayName() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> tokenUser;
      int member;
        final documents = await firestore.collection("member").get();
        member = documents.docChanges.length+1;
        print(member);
        memberid = member.toString();
    await _firebaseMessaging.getToken().then((String token) {
      tokenUser = [token];
    });
    Map<String, dynamic> map = Map();
    map['username'] = firebaseAuth.currentUser.displayName;
    map['userId'] = "${now.year}$memberid";
    map['photo'] = firebaseAuth.currentUser.photoURL;
    map['stucode'] = stucode.text;
    map['phone'] = phoneNumber.text;
    map['photo'] = urlPhoto;
    map['tokenUser'] = FieldValue.arrayUnion(tokenUser);
    map['userStatus'] = "user";

    var user = firebaseAuth.currentUser;
    if (user != null) {
      await firestore.collection("member").doc(user.uid).set(map).then((value) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
    print(user);
  }

  Widget galleryButton() {
    return IconButton(
        icon: Icon(Icons.add_photo_alternate),
        onPressed: () {
          getImage(ImageSource.gallery, 0);
        });
  }

  Widget cameraButton() {
    return IconButton(
        icon: Icon(Icons.add_a_photo),
        onPressed: () {
          getImage(ImageSource.camera, 0);
        });
  }

  Future getImage(ImageSource imageSource, int index) async {
    final pickedFile = await picker.getImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
    );

    setState(() {
      if (pickedFile != null) {
        if (index == 0) {
          _image = File(pickedFile.path);
        } else {
          _imgReceipt = File(pickedFile.path);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("สมัครสมาชิก"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                key: keyfrom,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("ข้อมูลร้านค้า"),
                      Divider(),
                      _createinput(
                          controller: stucode,
                          hinttext: "รหัสนักศึกษา",),
                      _createinput(
                          controller: phoneNumber,
                          hinttext: "เบอร์โทรศัพท์",
                          keyboardType: TextInputType.number,
                          maxLength: 10),
                      SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_alt),
                                  statusBool ? CircularProgressIndicator() : Text("บันทึกข้อมูล"),
                                ],
                              ),
                              onPressed: statusBool ? (){} : () => _onSave())),
                    ],
                  ),
                )),
          ),
        ));
  }

  Widget _createinput(
      {@required TextEditingController controller,
      @required String hinttext,
      TextInputType keyboardType = TextInputType.text,
      bool isPassword = false,
      int maxLength = 100}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: TextFormField(
        maxLength: maxLength,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        validator: (msx) {
          if (msx.isEmpty) return "input valid";
          return null;
        },
        decoration: InputDecoration(
          hintText: hinttext,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(255, 51, 247, 1)),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(255, 51, 247, 1)),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }
}
