import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  TextEditingController emailInputController;
  TextEditingController passwordInputController;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  String email, password;

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else if (regex == null) {
      return 'Please enter an email address';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    emailInputController = TextEditingController();
    passwordInputController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Form(
          key: loginFormKey,
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment(0.9, 0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: size.width / 7),
                      Center(
                        child: Text(
                          'Log in',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: size.width / 5),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              size: 30,
                            ),
                            labelText: 'Email'),
                        onChanged: (value) {
                          email = value;
                        },
                        controller: emailInputController,
                        validator: emailValidator,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, size: 30),
                            labelText: 'Password'),
                        validator: pwdValidator,
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 25),
                      MaterialButton(
                          color: Colors.amber,
                          minWidth: 250,
                          elevation: 10,
                          height: size.width / 10,
                          child: Text(
                            'Log in',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1,
                                fontSize: 18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          onPressed: () async {
                            if (loginFormKey.currentState.validate()) {
                              try {
                                setState(() {
                                  isLoading = true;
                                });
                                final loginUser =
                                    await _auth.signInWithEmailAndPassword(
                                        email: email, password: password);
                                if (loginUser != null) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.popAndPushNamed(context, '/home');
                                } else {
                                  setState(() {
                                    isLoading = false;
                                    FlutterToast.showToast(
                                        msg: "Incorrect password/username",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                  FlutterToast.showToast(
                                      msg: "Incorrect password/username",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                });
                              }
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
