import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:myshop/screens/home.dart';
import 'package:myshop/services/auth.dart';
import 'package:myshop/services/database.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  WifiInfoWrapper _wifiObject;
  bool isLoading = false;
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  String email, password, firstName, lastName, mac;

  Future<void> initPlatformState() async {
    WifiInfoWrapper wifiObject;
    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;
    } on PlatformException {}
    if (!mounted) return;
    setState(() {
      _wifiObject = wifiObject;
    });
  }

  String pwdValidator(String value) {
    if (value.length < 6) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  String nameValidator(String value) {
    if (value.length < 2) {
      return 'Enter Your name';
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

  CollectionReference collectionReference =
      Firestore.instance.collection('users');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    mac = _wifiObject != null ? _wifiObject.macAddress.toString() : "ip";
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Form(
          key: loginFormKey,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment(-0.9, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.keyboard_backspace),
                    ),
                  ),
                  SizedBox(height: size.width / 7),
                  Center(
                    child: Text(
                      'Sign Up',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: size.width / 5),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'First Name'),
                            validator: nameValidator,
                            onChanged: (value) {
                              firstName = value;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Last Name'),
                            validator: nameValidator,
                            onChanged: (value) {
                              lastName = value;
                            },
                            obscureText: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
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
                      elevation: 2,
                      height: size.width / 10,
                      child: Text(
                        'Log in',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1,
                            fontSize: 18),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () async {
                        if (loginFormKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          dynamic result =
                              await _authService.register(email, password);
                          if (result == null) {
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            await DatabaseService(userEmail: email)
                                .setUserData(email, firstName, lastName, mac);
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(userEmail: email),
                              ),
                            );
                          }
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
