import 'package:bsrufood/srceen/auth_controller.dart';
import 'package:bsrufood/srceen/singin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

final keyfrom = GlobalKey<FormState>();
final userController = TextEditingController();
final passwordController = TextEditingController();
final email = TextEditingController();
Authcontroller authController;
String msg = "";
final facebookLogin = FacebookLogin();
FirebaseAuth firebaseAuth = FirebaseAuth.instance;

void _onLogin() {
  if (keyfrom.currentState.validate()) {
    keyfrom.currentState.save();
    authController.onLogin(
        email: userController.text, password: passwordController.text);
  }
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    authController = Authcontroller(context);
  }

  void showdialog(){
    Alert(
      context: context,
      title: "ลืมรหัสผ่าน?",
      content: Column(children: [
        _createinput(controller: email,hinttext: "E-mail",keyboardType: TextInputType.emailAddress),
        Text(msg,style: TextStyle(color: Colors.red),)
      ],),
      buttons: [
          DialogButton(
          child: Text("กดเพื่อส่งข้อมูล",style: TextStyle(color: Colors.white),),
          color: Color.fromRGBO(255, 51, 247, 1.0),
          onPressed: (){
            if(email.text == ""){
              setState(() {
                msg = "กรุณากรอกอีเมล";
              });
              Navigator.pop(context);
              showdialog();
            }else{
                firebaseAuth.sendPasswordResetEmail(email: email.text).catchError((e,sd){
                   msg = "";
                  setState(() {});
                  Navigator.pop(context);
                  alertstatus("ไม่สำเร็จ",AlertType.error, "กรุณากดส่งใหม่อีกครั้ง");
                }).then((value){
                  msg = "";
                  email.clear();
                  setState(() {});
                  Navigator.pop(context);
                  alertstatus("สำเร็จ",AlertType.success, "ไปที่อีเมลเพื่อยืนยันรหัสผ่าน");
                });
              }
            
          })
      ],
      
    ).show();
  }

  void alertstatus(String status,AlertType icon,String desc){
    Alert(type: icon,
          context: context,
          title: status,
          desc: desc,
          buttons: [
            DialogButton(child: Text("ตกลง",style: TextStyle(color: Colors.white),),
            onPressed: ()=>Navigator.pop(context),
            )
          ]
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    "images/logo.jpg",
                    width: 200,
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Form(
                    key: keyfrom,
                    child: Column(
                      children: [
                        _createinput(
                            controller: userController,
                            hinttext: "E-mail",
                            isPassword: false),
                        _createinput(
                            controller: passwordController,
                            hinttext: "Password",
                            isPassword: true),
                        Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: ()=>showdialog(),
                              child: Text(
                                "ลืมรหัสผ่าน ?",
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 18),
                              ),
                            )),
                        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: Color.fromRGBO(255, 51, 247, 1.0),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text("เข้าสู่ระบบ",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                              onPressed: () {
                                _onLogin();
                              }),
                        ),
                        Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text("สมัครสมาชิก",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                              onPressed: () {
                                MaterialPageRoute route = MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Register());
                                Navigator.push(context, route);
                              }),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                              child: Column(
                                children: [
                                  Text("เชื่อมต่อด้วย"),
                                  Divider(),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(vertical: 30)),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "images/fb.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5)),
                                  Text("Facebook",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                ],
                              ),
                              onPressed: () =>
                                  authController.loginWithFacebook(context)),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createinput(
      {@required TextEditingController controller,
      @required String hinttext,
      TextInputType keyboardType = TextInputType.text,
      bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: TextFormField(
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
