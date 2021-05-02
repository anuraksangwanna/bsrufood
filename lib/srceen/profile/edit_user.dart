import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
class EditUser extends StatefulWidget {
  final Map user ;
  EditUser(this.user);

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
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
  String urlPhoto , urlPhoto1;

  @override
  void initState() { 
    super.initState();
    urlPhoto = widget.user["photo"];
    name.text = widget.user["username"];
    stucode.text = widget.user["stucode"];
    phoneNumber.text = widget.user["phone"];
    statusBool = false;
    // print(memberid);
  }

  void _onSave() {
      if (keyfrom.currentState.validate()) {
        keyfrom.currentState.save();
        registerThread();
        print(passwordController.text);
      }
  }
  

  Future<void> uploadPictureToStore() async {
    Random random = Random();
    int i = random.nextInt(100000);

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    if (_image != null) {
      await firebaseStorage.ref().child('Member/member$i.jpg').putFile(_image);
      urlPhoto = await firebaseStorage
          .ref()
          .child('Member/member$i.jpg')
          .getDownloadURL();
    } else {
      urlPhoto = widget.user["photo"];
    }
    await setupDisplayName();
  }

  Future<void> registerThread() async {
    setState(() {
      statusBool = true;
    });
    uploadPictureToStore();
  }

  Future<void> setupDisplayName() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> tokenUser;
      // int member;
      //   final documents = await firestore.collection("member").get();
      //   member = documents.docChanges.length+1;
      //   print(member);
      //   memberid = member.toString();
    await _firebaseMessaging.getToken().then((String token) {
      tokenUser = [token];
    });
    Map<String, dynamic> map = Map();
    map['username'] = name.text;
    map['photo'] = urlPhoto;
    map['stucode'] = stucode.text;
    map['phone'] = phoneNumber.text;
    map['tokenUser'] = FieldValue.arrayUnion(tokenUser);
    map['userStatus'] = "user";

    var user = firebaseAuth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: name.text, photoURL: urlPhoto);
      await firestore.collection("member").doc(user.uid).update(map).then((value) {
        Navigator.pop(context);
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
                      Text("รูปภาพนักศึกษา"),
                      Divider(),
                      _image != null
                          ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                image: FileImage(_image),
                                fit: BoxFit.cover
                              )
                            ),
                            width:200,
                            height:200,
                          )
                          : urlPhoto == null
                              ? Text("กำลังโหลดรูป")
                              : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                image: NetworkImage(urlPhoto)
                                ,fit: BoxFit.cover
                              )
                            ),
                            width:200,
                            height:200,
                          ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cameraButton(),
                          Padding(padding: EdgeInsets.only(right: 70)),
                          galleryButton()
                        ],
                      ),
                      Text("ข้อมูลนักศึกษา"),
                      Divider(),
                      _createinput(
                          controller: name,
                          hinttext: "ชื่อ",
                          maxLength: 50),
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
